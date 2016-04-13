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

#import "CBWRecovery.h"
#import "CBWiCloud.h"

@interface RecoverViewController ()<MasterPasswordViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) CBWRecovery *recovery;
@end

@implementation RecoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    
    CGFloat stageWidth = CGRectGetWidth(self.view.frame);
    CGFloat stageHeight = CGRectGetHeight(self.view.frame);
    
    if ([CBWiCloud isiCloudAccountSignedIn]) {
        PrimaryButton *iCloudButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f, stageWidth - 40.f, CBWCellHeightDefault)];
        [iCloudButton addTarget:self action:@selector(p_handleFetchiCloudData:) forControlEvents:UIControlEventTouchUpInside];
        [iCloudButton setTitle:NSLocalizedStringFromTable(@"Button recover_from_icloud", @"CBW", nil) forState:UIControlStateNormal];
        [self.view addSubview:iCloudButton];
    }
    
    PrimaryButton *photoLibraryButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f + CBWCellHeightDefault + 16.f, stageWidth - 40.f, CBWCellHeightDefault)];
    [photoLibraryButton addTarget:self action:@selector(p_handleOpenPhotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [photoLibraryButton setTitle:NSLocalizedStringFromTable(@"Button photo_library", @"CBW", "Photo Library") forState:UIControlStateNormal];
    [self.view addSubview:photoLibraryButton];
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

- (void)p_handleFetchiCloudData:(id)sender {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    CBWiCloud *iCloud = [[CBWiCloud alloc] init];
    [iCloud fetchBackupDataWithCompletion:^(NSError *error, id data) {
        [indicator stopAnimating];
        if (data) {
            self.recovery = [[CBWRecovery alloc] initWithDatas:data];
            if (self.recovery) {
                [self p_handleNext:nil];
            }
        }
    }];
}

- (void)p_handleOpenPhotoLibrary:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - <MasterPasswordViewControllerDelegate>
- (void)masterPasswordViewController:(MasterPasswordViewController *)controller didInputPassword:(NSString *)password {
    DLog(@"try to recover with code with code");
    
    if ([self.recovery recoverWithCode:password]) {
        // notification
        [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationWalletCreated object:nil];
        // thank you, go
        InitialWalletSettingViewController *initialWalletSettingViewController = [[InitialWalletSettingViewController alloc] init];
        initialWalletSettingViewController.delegate = (LockScreenController *)self.navigationController;
        [self.navigationController pushViewController:initialWalletSettingViewController animated:YES];
    };
}

#pragma mark <UIImagePickerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    
    self.recovery = [[CBWRecovery alloc] initWithAssetURL:url];
    if (self.recovery) {
        [self p_handleNext:nil];
    }
}

@end
