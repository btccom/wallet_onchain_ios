//
//  AddressViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressViewController.h"
//#import "AddressHeaderView.h"
#import "AddressCardView.h"
#import "TransactionViewController.h"
#import "AddressListViewController.h"

#import "Database.h"
#import "CBWRequest.h"
#import "BlockMonitor.h"

#import "NSDate+Helper.h"
#import "NSString+CBWAddress.h"

@interface AddressViewController ()<UIScrollViewDelegate, UITextFieldDelegate, CBWTXStoreDelegate>

@property (nonatomic, strong) CBWTXStore *transactionStore;
@property (nonatomic, assign) BOOL isThereMoreDatas;

@property (nonatomic, strong) NSString *addressString;

@property (nonatomic, weak) UIView *qrCodeView;
@property (nonatomic, weak) UIImageView *qrCodeImageView;

@end

@implementation AddressViewController

- (UIView *)qrCodeView {
    if (!_qrCodeView) {
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.alpha = 0;
        view.hidden = YES;
        
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        blurView.frame = view.bounds;
        [view addSubview:blurView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - HD_IMAGE_PORTRAIT_HEIGHT) / 2.f, (SCREEN_HEIGHT - HD_IMAGE_PORTRAIT_HEIGHT) / 2.f, HD_IMAGE_PORTRAIT_HEIGHT, HD_IMAGE_PORTRAIT_HEIGHT)];
        [view addSubview:imageView];
        _qrCodeImageView = imageView;
        
        NSString *qrcodeString = self.address.address;
        if (self.address.label.length > 0) {
            qrcodeString = [NSString stringWithFormat:@"bitcoin:%@?label=%@", self.address.address, self.address.label];
        }
        [imageView setImage:[qrcodeString qrcodeImageWithSize:imageView.frame.size]];
        
        UIButton *button = [[UIButton alloc] initWithFrame:view.bounds];
        [button addTarget:self action:@selector(p_handleDismissQRCodeImage) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        [self.view addSubview:view];
        _qrCodeView = view;
    }
    return _qrCodeView;
}

- (CBWTXStore *)transactionStore {
    if (!_transactionStore) {
        _transactionStore = [[CBWTXStore alloc] init];
        _transactionStore.delegate = self;
        _transactionStore.queryAddresses = @[self.addressString];
    }
    return _transactionStore;
}

- (NSString *)addressString {
    if (!_addressString) {
        _addressString = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsTestnetEnabled] ? self.address.testAddress : self.address.address;
    }
    return _addressString;
}

#pragma mark - Initialization

- (instancetype)initWithAddress:(CBWAddress *)address actionType:(AddressActionType)actionType {
//    self = [super initWithStyle:(actionType == AddressActionTypeDefault) ? UITableViewStylePlain : UITableViewStyleGrouped];
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _address = address;
        _actionType = actionType;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return nil;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    AddressHeaderView *addressHeaderView = [[AddressHeaderView alloc] init];
//    [addressHeaderView setAddress:self.addressString withLabel:self.address.label];
//    addressHeaderView.delegate = self;
//    [self.tableView setTableHeaderView:addressHeaderView];
    
    AddressCardView *headerView = [[AddressCardView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HD_IMAGE_PORTRAIT_HEIGHT)];
    headerView.addressLabelField.text = self.address.label;
    headerView.addressLabelField.returnKeyType = UIReturnKeyDone;
    headerView.addressLabelField.delegate = self;
    [headerView.addressLabelField addTarget:self action:@selector(p_handleLabelEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    headerView.addressLabel.text = self.address.address;
    headerView.balanceLabel.text = [@(self.address.balance) satoshiBTCString];
    headerView.receivedLabel.text = [@(self.address.received) satoshiBTCString];
    headerView.txLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.address.txCount];
    [headerView.qrcodeButton addTarget:self action:@selector(p_handlePresentQRCodeImage) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headerView;
    
    DLog(@"action type: %ld", (long)self.actionType);
    switch (self.actionType) {
        case AddressActionTypeDefault: {
            self.title = NSLocalizedStringFromTable(@"Navigation address", @"CBW", @"Address");
            
            [self.transactionStore fetch];
            [self.tableView reloadData];
            
            if (!self.refreshControl) {
                self.refreshControl = [[UIRefreshControl alloc] init];
                [self.refreshControl addTarget:self action:@selector(p_requestAddressSummary) forControlEvents:UIControlEventValueChanged];
            }
            
            // 请求摘要及交易信息
            [self p_requestAddressSummary];
            
            break;
        }
            
        case AddressActionTypeCreate: {
            self.title = NSLocalizedStringFromTable(@"Navigation create_address", @"CBW", nil);
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(p_handleSaveNewAddress:)];
            break;
        }
            
        default: {
            NSAssert(AddressActionTypeDefault == self.actionType || AddressActionTypeCreate == self.actionType, @"Address view controller won't support this action.");
            break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.actionType == AddressActionTypeCreate) {
        // 删除
        [self.address deleteFromStore];
    }
}

#pragma mark - Private Method
#pragma mark Request Logic
- (void)p_requestAddressSummary {
    if (self.requesting) {
        DLog(@"fetching");
        return;
    }
    
    [self requestDidStart];
    
    CBWRequest *request = [[CBWRequest alloc] init];
    // 获取地址信息
    [request addressSummaryWithAddressString:self.addressString completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [self requestDidStop];
        // 更新地址信息
        [self.address updateWithDictionary:response];
        AddressCardView *headerView = (AddressCardView *)self.tableView.tableHeaderView;
        headerView.balanceLabel.text = [@(self.address.balance) satoshiBTCString];
        headerView.receivedLabel.text = [@(self.address.received) satoshiBTCString];
        headerView.txLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.address.txCount];
        [headerView setNeedsLayout];
        // 保存地址信息
        if (self.address.rid >= 0) {
            [self.address saveWithError:nil];
        }
        if (self.address.txCount > 0) {
            // 重置分页信息后获取交易
            [self p_requestTransactions];
        }
    }];
}
- (void)p_requestTransactions {
    if (self.transactionStore.page < self.transactionStore.pageTotal) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.transactionStore fetchNextPage];
        });
    }
}

#pragma mark Handlers
- (void)p_handleBackToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)p_handleSaveNewAddress:(id)sender {
    [self reportActivity:@"saveNewAddress"];
    
    [self.view endEditing:YES];
    
    [self.address saveWithError:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)p_handleShare:(id)sender {
    DLog(@"clicked share");
}

- (void)p_handleArchive:(id)sender {
    DLog(@"clicked archive, %ld, %ld", (long)self.address.accountIDX, (long)self.address.idx);
    if (self.address.accountIDX == CBWRecordWatchedIDX) {
        DLog(@"to delete watched address");
        [self.address deleteWatchedAddressFromStore:self.address.store];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.address.archived = !self.address.archived;
    [self.address saveWithError:nil];
    
    // pop back
    if (((CBWAddressStore *)self.address.store).isArchived) {
        // 检查是否为空
        if (self.address.store.count == 0) {
            // TODO: improve
            NSArray *viewControllers = self.navigationController.viewControllers;
            UIViewController *vc = [viewControllers objectAtIndex:(viewControllers.count - 3)];
            if ([vc isKindOfClass:[AddressListViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)p_handleLabelEditingChanged:(UITextField *)field {
    [self reportActivity:@"addressLabelChanged"];
    self.address.label = field.text;
    if (self.actionType != AddressActionTypeCreate) {
        [self.address saveWithError:nil];
    }
}
- (void)p_handlePresentQRCodeImage {
    
    NSString *qrcodeString = self.address.address;
    if (self.address.label.length > 0) {
        qrcodeString = [NSString stringWithFormat:@"bitcoin:%@?label=%@", self.address.address, self.address.label];
    }
    [self.qrCodeImageView setImage:[qrcodeString qrcodeImageWithSize:self.qrCodeImageView.frame.size]];
    
    [self.view bringSubviewToFront:self.qrCodeView];
    self.qrCodeView.hidden = NO;
    
    [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
        self.qrCodeView.alpha = 1;
    }];
}

- (void)p_handleDismissQRCodeImage {
    [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
        self.qrCodeView.alpha = 0;
    } completion:^(BOOL finished) {
        self.qrCodeView.hidden = YES;
    }];
}

#pragma mark - UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.transactionStore numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.transactionStore numberOfRowsInSection:section];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDate *today = [NSDate date];
    NSString *day = [self.transactionStore dayInSection:section];
    if ([today isInSameDayWithDate:[NSDate dateFromString:day withFormat:@"yyyy-MM-dd"]]) {
        return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
    }
    return day;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
    if (!transaction) {
        DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"NaN";
        // return empty cell
        return cell;
    }
    transaction.latestBlockHeight = [BlockMonitor defaultMonitor].height;
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
    [cell setTransaction:transaction];
    return cell;
}

#pragma mark <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CBWListSectionHeaderHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CBWCellHeightTransaction;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == AddressActionTypeDefault) {
        // goto transaction
        CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
        if (transaction) {
            TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
            [self.navigationController pushViewController:transactionViewController animated:YES];
        }
    }
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.transactionStore.page < self.transactionStore.pageTotal) {
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat offsetTop = targetContentOffset->y;
        CGFloat height = CGRectGetHeight(scrollView.frame);
        if (contentHeight - (offsetTop + height) < 2 * CBWCellHeightTransaction) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.transactionStore fetchNextPage];
            });
        }
    }
}

#pragma mark - <CBWTXStoreDelegate>
- (void)txStoreDidCompleteFetch:(CBWTXStore *)store {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - <UITextFieldDelegat>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
