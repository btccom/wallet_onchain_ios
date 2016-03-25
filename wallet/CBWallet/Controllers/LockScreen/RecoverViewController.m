//
//  RecoverViewController.m
//  CBWallet
//
//  Created by Zin on 16/3/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecoverViewController.h"
#import "LockScreenController.h"
#import "MasterPasswordViewController.h"
#import "InitialWalletSettingViewController.h"

#import "PrimaryButton.h"

@interface RecoverViewController ()<MasterPasswordViewControllerDelegate>

@end

@implementation RecoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    
    CGFloat stageWidth = CGRectGetWidth(self.view.frame);
    CGFloat stageHeight = CGRectGetHeight(self.view.frame);
    PrimaryButton *createButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f, stageWidth - 40.f, CBWCellHeightDefault)];
    [createButton addTarget:self action:@selector(p_handleNext:) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:NSLocalizedStringFromTable(@"Button scan_qrcode", @"CBW", "Scan QRCode") forState:UIControlStateNormal];
    [self.view addSubview:createButton];
    PrimaryButton *recoverButton = [[PrimaryButton alloc] initWithFrame:CGRectOffset(createButton.frame, 0, CBWCellHeightDefault + 16.f)];
    [recoverButton addTarget:self action:@selector(p_handleNext:) forControlEvents:UIControlEventTouchUpInside];
    [recoverButton setTitle:NSLocalizedStringFromTable(@"Button photo_library", @"CBW", "Photo Library") forState:UIControlStateNormal];
    [self.view addSubview:recoverButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)p_handleNext:(id)sender {
    MasterPasswordViewController *masterPasswordViewController = [[MasterPasswordViewController alloc] init];
    masterPasswordViewController.actionType = LockScreenActionTypeSignIn;
    masterPasswordViewController.hint = @"Hint From Backup";
    masterPasswordViewController.delegate = self;
    [self.navigationController pushViewController:masterPasswordViewController animated:YES];
}

#pragma mark - <MasterPasswordViewControllerDelegate>
- (void)masterPasswordViewController:(MasterPasswordViewController *)controller didInputPassword:(NSString *)password {
    DLog(@"try to recover with code: %@", password);
    
    // decode qr code image
    // get uuid
    // get encrypted seed
    // get pbkdf2 key from password with uuid (as salt)
    // decrypt seed
    // save uuid to keychain
    // save encrypted seed to keychain
    // next
    InitialWalletSettingViewController *initialWalletSettingViewController = [[InitialWalletSettingViewController alloc] init];
    initialWalletSettingViewController.delegate = (LockScreenController *)self.navigationController;
    [self.navigationController pushViewController:initialWalletSettingViewController animated:YES];
}

@end
