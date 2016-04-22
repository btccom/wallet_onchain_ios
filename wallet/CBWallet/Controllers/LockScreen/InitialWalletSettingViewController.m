//
//  SignInSettingViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "InitialWalletSettingViewController.h"

#import "PrimaryButton.h"

//#import "SystemManager.h"
#import "CBWBackup.h"

@import LocalAuthentication;

@interface InitialWalletSettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UISwitch *iCloudSwitch;
@property (nonatomic, weak) UISwitch *touchIDSwitch;

@end

@implementation InitialWalletSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    self.title = NSLocalizedStringFromTable(@"Navigation initial_wallet_setting", @"CBW", @"Initial Wallet Setting");
    
    // remove back
    [self.navigationItem setHidesBackButton:YES];
    self.navigationController.viewControllers = @[self];
    
    // default
    if ([[NSUserDefaults standardUserDefaults] objectForKey:CBWUserDefaultsiCloudEnabledKey] == nil) {
//        if ([[SystemManager defaultManager] isiCloudAccountSignedIn]) {
        if ([CBWBackup isiCloudAccountSignedIn]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CBWUserDefaultsiCloudEnabledKey];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CBWUserDefaultsiCloudEnabledKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor CBWWhiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)p_handleCreate:(id)sender {
    [self.delegate initialWalletSettingViewControllerDidComplete:self];
}

- (void)p_toggleiCloudEnabled:(id)sender {
    [CBWBackup toggleiCloudBySwith:sender inViewController:self];
}

- (void)p_toggleTouchIDEnabled:(id)sender {
    // TODO: toggle touch id
    if ([sender isEqual:self.touchIDSwitch]) {
        return;
    }
    self.touchIDSwitch.on = !self.touchIDSwitch.on;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSError *error = nil;
    LAContext *laContext = [[LAContext alloc] init];
    if (![laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        return 1;
    }
    return 2;// iCloud, Touch ID
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"cell-%lu-%lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        switch (indexPath.section) {
            case 0: {
                cell.textLabel.text = NSLocalizedStringFromTable(@"Initial Cell icloud", @"CBW", @"iCloud");
                UISwitch *aSwitch = [[UISwitch alloc] init];
                aSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsiCloudEnabledKey];
                [aSwitch addTarget:self action:@selector(p_toggleiCloudEnabled:) forControlEvents:UIControlEventValueChanged];
                self.iCloudSwitch = aSwitch;
                cell.accessoryView = aSwitch;
                break;
            }
            case 1: {
                cell.textLabel.text = NSLocalizedStringFromTable(@"Initial Cell touch_id", @"CBW", @"Touch ID");
                UISwitch *aSwitch = [[UISwitch alloc] init];
                aSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsTouchIdEnabledKey];
                [aSwitch addTarget:self action:@selector(p_toggleTouchIDEnabled:) forControlEvents:UIControlEventValueChanged];
                self.touchIDSwitch = aSwitch;
                cell.accessoryView = aSwitch;
                break;
            }
        }
    }
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == tableView.numberOfSections - 1) {

        CGFloat stageWidth = CGRectGetWidth(self.view.frame);
        
        UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, stageWidth, CBWCellHeightDefault + CBWLayoutCommonVerticalPadding * 3.f)];

        PrimaryButton *button = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, CBWCellHeightDefault, stageWidth - 40.f, CBWCellHeightDefault)];
        [button setTitle:NSLocalizedStringFromTable(@"Button complete", @"CBW", @"Complete Initial Settings") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p_handleCreate:) forControlEvents:UIControlEventTouchUpInside];
        [view.contentView addSubview:button];
        
        return view;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == tableView.numberOfSections - 1) {
        return CBWCellHeightDefault + CBWLayoutCommonVerticalPadding * 3.f;
    }
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            [self p_toggleiCloudEnabled:nil];
            break;
            
        default:
            [self p_toggleTouchIDEnabled:nil];
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
