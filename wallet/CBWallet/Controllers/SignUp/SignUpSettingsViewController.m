//
//  SignUpSettingsViewController.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SignUpSettingsViewController.h"

#import "PrimarySolidButton.h"

#import "CBWBackup.h"

@interface SignUpSettingsViewController ()

@property (nonatomic, weak) UISwitch *iCloudSwitch;

@end

@implementation SignUpSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat padding = CBWLayoutCommonPadding;
    
    // touch id
    // can not set here
    
    // icloud
    UILabel *iCloudLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, HD_IMAGE_PORTRAIT_HEIGHT + padding, SCREEN_WIDTH - padding * 2, CBWCellHeightDefault)];
    iCloudLabel.text = NSLocalizedStringFromTable(@"Initial Cell icloud", @"CBW", nil);
    [self.view addSubview:iCloudLabel];
    
    UISwitch *aSwitch = [[UISwitch alloc] init];
    CGFloat aSwitchWidth = CGRectGetWidth(aSwitch.frame);
    CGFloat aSwitchHeight = CGRectGetHeight(aSwitch.frame);
    aSwitch.frame = CGRectMake(CGRectGetMaxX(iCloudLabel.frame) - aSwitchWidth, CGRectGetMidY(iCloudLabel.frame) - aSwitchHeight / 2.f, aSwitchWidth, aSwitchHeight);
    aSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsiCloudEnabledKey];
    [aSwitch addTarget:self action:@selector(p_toggleiCloudEnabled:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aSwitch];
    _iCloudSwitch = aSwitch;
    
    // next button
    PrimarySolidButton *completeButton = [[PrimarySolidButton alloc] initWithFrame:CGRectOffset(iCloudLabel.frame, 0, CBWCellHeightDefault + padding)];
    [completeButton setTitle:NSLocalizedStringFromTable(@"Button complete", @"CBW", nil) forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(p_handleComplete) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    DLog(@"sign up dealloc!");
}

#pragma mark - Private Method

- (void)p_toggleiCloudEnabled:(id)sender {
    [CBWBackup toggleiCloudBySwith:sender inViewController:self];
}

- (void)p_handleComplete {
    [self.delegate signUpSettingsViewControllerDidComplete:self];
}

@end
