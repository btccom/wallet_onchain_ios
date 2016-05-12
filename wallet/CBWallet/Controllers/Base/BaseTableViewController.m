//
//  BaseTableViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseTableViewController.h"

#import "UIViewController+Appearance.h"

NSString *const BaseTableViewSectionHeaderIdentifier = @"list.section.header";
NSString *const BaseTableViewCellDefaultIdentifier = @"cell.default";
NSString *const BaseTableViewCellActionButtonIdentifier = @"cell.button.action";
NSString *const BaseTableViewCellBlockButtonIdentifier = @"cell.button.block";

@interface BaseTableViewController ()<UIScrollViewDelegate>

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    
    [self.tableView registerClass:[DefaultSectionHeaderView class] forHeaderFooterViewReuseIdentifier:BaseTableViewSectionHeaderIdentifier];
    [self.tableView registerClass:[DefaultTableViewCell class] forCellReuseIdentifier:BaseTableViewCellDefaultIdentifier];
    [self.tableView registerClass:[FormControlActionButtonCell class] forCellReuseIdentifier:BaseTableViewCellActionButtonIdentifier];
    [self.tableView registerClass:[FormControlBlockButtonCell class] forCellReuseIdentifier:BaseTableViewCellBlockButtonIdentifier];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
//    UIControl *backgroundView = [[UIControl alloc] initWithFrame:self.view.bounds];
//    [backgroundView addTarget:self action:@selector(p_dismissKeyboard) forControlEvents:UIControlEventTouchDown];
//    self.tableView.backgroundView = backgroundView;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reportActivity:ActivityMonitorActViewDidAppear];
}

#pragma mark - Public Method
- (void)dismiss:(id)sender {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CBWCellHeightDefault;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DefaultSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:BaseTableViewSectionHeaderIdentifier];
    headerView.topHairlineHidden = YES;
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section].length > 0) {
        if (section == 0) {
            return CBWCellHeightDefault;
        }
        return CBWListSectionHeaderHeight;
    }
    return 0;// auto
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Method
- (void)p_dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self reportActivity:@"scroll"];
}

@end
