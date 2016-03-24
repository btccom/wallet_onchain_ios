//
//  SendViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendViewController.h"

@interface SendViewController ()

@end

@implementation SendViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send") style:UIBarButtonItemStylePlain target:self action:@selector(p_handleSwitchMode:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // TODO: cache the send data
}

#pragma mark - Private Method

#pragma mark Handlers

/// clicked navigation right button to switch mode
- (void)p_handleSwitchMode:(id)sender {
    switch (self.mode) {
        case SendViewControllerModeQuickly: {
            // to advanced
            self.mode = SendViewControllerModeAdvanced;
            self.title = NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send");
            self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Navigation Send", @"CBW", @"Quickly Send");
            break;
        }
        case SendViewControllerModeAdvanced: {
            // to quickly
            self.mode = SendViewControllerModeQuickly;
            self.title = NSLocalizedStringFromTable(@"Navigation send", @"CBW", @"Quickly Send");
            self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Navigation advanced_send", @"CBW", @"Advanced Send");
            break;
        }
    }
    
    // reload table view
    [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
        self.tableView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
            self.tableView.alpha = 1.f;
        } completion:nil];
    }];
}

/// clicked send button
- (void)p_handleSend:(id)sender {
    
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger number = 0;
    switch (self.mode) {
        case SendViewControllerModeQuickly:
            number = 2;
            break;
            
        case SendViewControllerModeAdvanced:
            number = 5;
            break;
    }
    return number;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Fake Section Title";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @"Fake Cell";
    return cell;
}

@end
