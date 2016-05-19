//
//  CreateOrRecoverViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CreateOrRecoverViewController.h"
#import "LockScreenController.h"
// create
#import "MasterPasswordViewController.h"
#import "InitialWalletSettingViewController.h"
// recover
#import "RecoverViewController.h"

#import "PrimaryButton.h"

#import "Guard.h"
#import "Database.h"

#import "SSKeychain.h"
#import "AESCrypt.h"

@interface CreateOrRecoverViewController ()<MasterPasswordViewControllerDelegate>

@end

@implementation CreateOrRecoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"Navigation create_or_recover", @"CBW", @"Welcome");
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    
    CGFloat stageWidth = CGRectGetWidth(self.view.frame);
    CGFloat stageHeight = CGRectGetHeight(self.view.frame);
    PrimaryButton *createButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f, stageWidth - 40.f, CBWCellHeightDefault)];
    [createButton addTarget:self action:@selector(p_handleCreate:) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:NSLocalizedStringFromTable(@"Button create_wallet", @"CBW", "Create Wallet") forState:UIControlStateNormal];
    [self.view addSubview:createButton];
    PrimaryButton *recoverButton = [[PrimaryButton alloc] initWithFrame:CGRectOffset(createButton.frame, 0, CBWCellHeightDefault + 16.f)];
    [recoverButton addTarget:self action:@selector(p_handleRecover:) forControlEvents:UIControlEventTouchUpInside];
    [recoverButton setTitle:NSLocalizedStringFromTable(@"Button recover_wallet", @"CBW", "Recover Wallet") forState:UIControlStateNormal];
    [self.view addSubview:recoverButton];
}

#pragma mark - Private Method
- (void)p_handleCreate:(id)sender {
    MasterPasswordViewController *masterPasswordViewController = [[MasterPasswordViewController alloc] init];
    masterPasswordViewController.actionType = LockScreenActionTypeSignUp;
    masterPasswordViewController.delegate = self;
    [self.navigationController pushViewController:masterPasswordViewController animated:YES];
}
- (void)p_handleRecover:(id)sender {
    RecoverViewController *recoverViewController = [[RecoverViewController alloc] init];
    [self.navigationController pushViewController:recoverViewController animated:YES];
}

#pragma mark - <MasterPasswordViewControllerDelegate>
- (void)masterPasswordViewController:(MasterPasswordViewController *)controller didInputPassword:(NSString *)password {
    NSLog(@"create wallet");
    // create seed
    NSString *seed = [NSString randomStringWithLength:64];
    // encrypt seed with key
    NSString *encryptedSeed = [AESCrypt encrypt:seed password:password];
    // save encrypted seed hex to keychain
    [SSKeychain setPassword:encryptedSeed forService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
    // call guard to check and cache password
    if ([[Guard globalGuard] checkInWithCode:password]) {
        // create first account
        CBWAccountStore *store = [[CBWAccountStore alloc] init];
        NSError *error = nil;
        CBWAccount *watchedAccount = [CBWAccount newAccountWithIdx:CBWRecordWatchedIDX label:NSLocalizedStringFromTable(AccountStoreWatchedAccountLabel, @"CBW", nil) inStore:store];
        DLog(@"create watched account: %@", watchedAccount.label);
        [watchedAccount saveWithError:&error];
        CBWAccount *account = [CBWAccount newAccountWithIdx:0 label:NSLocalizedStringFromTable(@"Label default_account", @"CBW", nil) inStore:store];
        DLog(@"create first account: %@", account.label);
        [account saveWithError:&error];
        if (error) {
            NSLog(@"create first account error: %@", error);
        }
        // notification
        [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationWalletCreated object:nil];
        // thank you, go
        InitialWalletSettingViewController *initialWalletSettingViewController = [[InitialWalletSettingViewController alloc] init];
        initialWalletSettingViewController.delegate = (LockScreenController *)self.navigationController;
        [self.navigationController pushViewController:initialWalletSettingViewController animated:YES];
    } else {
        // sorry, handle error
        NSLog(@"create then check in failed");
        // restart
        [SSKeychain deletePasswordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
        [SSKeychain deletePasswordForService:CBWKeychainHintService account:CBWKeychainAccountDefault];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
