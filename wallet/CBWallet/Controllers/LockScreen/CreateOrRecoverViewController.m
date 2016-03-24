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
#import "SSKeychain.h"

#import "NSString+PBKDF2.h"
#import "NSData+AES256.h"

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
    // create uuid
    NSString *uuid = [NSUUID UUID].UUIDString;
    // create seed
    NSString *seed = [NSString randomStringWithLength:64];
    NSLog(@"uuid: %@, seed: %@", uuid, seed);
    // get pbkdf2 key from password with uuid (as salt)
    NSString *key = [password PBKDF2KeyWithSalt:uuid];
    NSLog(@"pbkdf2 key: %@", key);
    // encrypt seed with key
    NSData *seedData = [seed dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedSeedData = [seedData AES256EncryptWithKey:key];
    NSLog(@"encrypted seed: %@", [encryptedSeedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]);
    // save uuid to key chain
    [SSKeychain setPassword:uuid forService:CBWKeyChainUUIDService account:CBWKeyChainAccountDefault];
    // save encrypted seed hex to keychain
    [SSKeychain setPasswordData:encryptedSeedData forService:CBWKeyChainSeedService account:CBWKeyChainAccountDefault];
    // call guard to check and cache password
    if ([[Guard globalGuard] checkInWithCode:password]) {
        // thank you, go
        InitialWalletSettingViewController *initialWalletSettingViewController = [[InitialWalletSettingViewController alloc] init];
        initialWalletSettingViewController.delegate = (LockScreenController *)self.navigationController;
        [self.navigationController pushViewController:initialWalletSettingViewController animated:YES];
    } else {
        // sorry, handle error
        // restart
    }
}

@end
