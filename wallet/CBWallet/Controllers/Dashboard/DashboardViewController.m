//
//  DashboardViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DashboardViewController.h"
#import "ProfileViewController.h"
#import "AddressListViewController.h"// explorer or receive
#import "ImagePickerController.h"// scan to explorer or send
#import "TransactionListViewController.h"// list all transactions
#import "TransactionViewController.h" // transaction detail
#import "SendViewController.h"// send

#import "DashboardHeaderView.h"

#import "Transaction.h"

#import "NSString+CBWAddress.h"
#import "Test.h"
#import "BTCQRCode.h"
#import "YYImage.h"

#import "AFNetworking.h"


@interface DashboardViewController ()<ProfileViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *transactions; // of Transaction
@end

@implementation DashboardViewController

#pragma mark - Property
- (NSMutableArray *)transactions {
    if (!_transactions) {
        _transactions = [[NSMutableArray alloc] init];
    }
    return _transactions;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedStringFromTable(@"Navigation Dashboard", @"CBW", @"Dashboard");
    
    // set navigation buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleProfile:)];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_address"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleAddressList:)], [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleScan:)]];
    
    // set table header
    CGFloat offsetHeight = -64.f;// status bar height + navigation bar height
    CGRect dashboardHeaderViewframe = self.view.bounds;
    dashboardHeaderViewframe.size.height = roundf(CGRectGetWidth(dashboardHeaderViewframe) / 16.f * 9.f) + offsetHeight;
    DashboardHeaderView *dashboardHeaderView = [[DashboardHeaderView alloc] initWithFrame:dashboardHeaderViewframe];
    [dashboardHeaderView.sendButton addTarget:self action:@selector(p_handleSend:) forControlEvents:UIControlEventTouchUpInside];
    [dashboardHeaderView.receiveButton addTarget:self action:@selector(p_handleReceive:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = dashboardHeaderView;
    
    // test
    // fake data
    for (NSInteger i = 0; i < 20; i++) {
        [self.transactions addObject:[Transaction new]];
    }
    
    // 测试 core bitcoin
    [Test runAllTests];
    
    // 测试二维码编码解码
    
    // 二维码生成
    NSString *qrcode1 = @"qr code string 1";
    NSString *qrcode2 = @"qr code string 2";
    UIImage *qrcodeImage1 = [BTCQRCode imageForString:qrcode1 size:CGSizeMake(200.f, 200.f) scale:2.f];
    UIImage *qrcodeImage2 = [BTCQRCode imageForString:qrcode2 size:CGSizeMake(200.f, 200.f) scale:2.f];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:qrcodeImage1];
    [self.view addSubview:imageView];
    
    // 编码
    YYImageEncoder *encoder = [[YYImageEncoder alloc] initWithType:YYImageTypePNG];
    encoder.loopCount = 0;
    [encoder addImage:qrcodeImage1 duration:0];
    [encoder addImage:qrcodeImage2 duration:0];
    NSData *apngData = [encoder encode];
    
    // 解码
    YYImageDecoder *decoder = [YYImageDecoder decoderWithData:apngData scale:2.f];
    UIImage *decodedQRCodeImage2 = [decoder frameAtIndex:1 decodeForDisplay:NO].image;
    
    // 获取二维码
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:nil] options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    if (detector) {
        NSLog(@"detector ready");
        CIImage *ciimg = [CIImage imageWithCGImage:decodedQRCodeImage2.CGImage];
        NSArray *featuresR = [detector featuresInImage:ciimg];
        NSString *decodeR;
        for (CIQRCodeFeature* featureR in featuresR) {
            NSLog(@"decode: %@ ",featureR.messageString);
            decodeR = featureR.messageString;
        }
    }
    
    // 测试 http 请求
    // 1. config session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 2. create manager with configuration
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    // 3. create request
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:@"https://chain.btc.com/api/v1/address/1F1MAvhTKg2VG29w8cXsiSN2PJ8gSsrJw" parameters:@{@"limit": @"10"} error:nil];
    // 4. fetch
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"OK: %@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
    
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
#pragma mark Navigation

/// present profile
- (void)p_handleProfile:(id)sender {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

/// push address list
- (void)p_handleAddressList:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] init];
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

/// present scan
- (void)p_handleScan:(id)sender {
    ImagePickerController *imagePickerViewController = [[ImagePickerController alloc] init];
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

/// push transactions
- (void)p_handleTransactionList:(id)sender {
    TransactionListViewController *transactionListViewController = [[TransactionListViewController alloc] init];
    [self.navigationController pushViewController:transactionListViewController animated:YES];
}

/// push send
- (void)p_handleSend:(id)sender {
    SendViewController *sendViewController = [[SendViewController alloc] init];
    [self.navigationController pushViewController:sendViewController animated:YES];
}

/// push address list to receive
- (void)p_handleReceive:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] init];
    addressListViewController.actionType = AddressActionTypeReceive;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
    Transaction *transaction = [self.transactions objectAtIndex:indexPath.row];
    if (transaction) {
        [cell setTransaction:transaction];
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CBWCellHeightTransaction;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Transaction *transaction = [self.transactions objectAtIndex:indexPath.row];
    if (transaction) {
        TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
        [self.navigationController pushViewController:transactionViewController animated:YES];
    }
}

#pragma mark - ProfileViewControllerDelegate
- (void)profileViewController:(ProfileViewController *)viewController didSelectAccount:(Account *)account {
    NSLog(@"selected account: %@", account);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
