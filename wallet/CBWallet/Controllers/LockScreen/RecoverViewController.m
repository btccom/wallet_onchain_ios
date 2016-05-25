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

#import "UIViewController+AlertMessage.h"

#import "PrimaryButton.h"

#import "CBWBackup.h"
#import "CBWRecovery.h"

@interface RecoverViewController ()<MasterPasswordViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) CBWRecovery *recovery;

@property (nonatomic, weak) UIButton *iCloudButton;
@property (nonatomic, weak) UIButton *photoLibraryButton;

@end

@implementation RecoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    
    CGFloat stageWidth = CGRectGetWidth(self.view.frame);
    CGFloat stageHeight = CGRectGetHeight(self.view.frame);
    
    if ([CBWBackup isiCloudAccountSignedIn]) {
        PrimaryButton *iCloudButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f, stageWidth - 40.f, CBWCellHeightDefault)];
        [iCloudButton addTarget:self action:@selector(p_handleFetchiCloudData:) forControlEvents:UIControlEventTouchUpInside];
        [iCloudButton setTitle:NSLocalizedStringFromTable(@"Button recover_from_icloud", @"CBW", nil) forState:UIControlStateNormal];
        [self.view addSubview:iCloudButton];
        _iCloudButton = iCloudButton;
    }
    
    PrimaryButton *photoLibraryButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f + CBWCellHeightDefault + 16.f, stageWidth - 40.f, CBWCellHeightDefault)];
    [photoLibraryButton addTarget:self action:@selector(p_handleOpenPhotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [photoLibraryButton setTitle:NSLocalizedStringFromTable(@"Button photo_library", @"CBW", "Photo Library") forState:UIControlStateNormal];
    [self.view addSubview:photoLibraryButton];
    _photoLibraryButton = photoLibraryButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)p_handleNext:(id)sender {
    MasterPasswordViewController *masterPasswordViewController = [[MasterPasswordViewController alloc] init];
    masterPasswordViewController.actionType = LockScreenActionTypeSignIn;
    masterPasswordViewController.hint = self.recovery.hint;
    masterPasswordViewController.delegate = self;
    [self.navigationController pushViewController:masterPasswordViewController animated:YES];
}

- (void)p_handleFetchiCloudData:(UIButton *)button {
    self.iCloudButton.enabled = NO;
    self.photoLibraryButton.enabled = NO;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    self.recovery = [[CBWRecovery alloc] init];
    [self.recovery fetchCloudKitDataWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.iCloudButton.enabled = YES;
            self.photoLibraryButton.enabled = YES;
            [indicator stopAnimating];
            
            if (error) {
                [self alertMessage:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil)];
            } else {
                [self p_handleNext:nil];
            }
        });
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
        [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationWalletRecovered object:nil];
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
        
        self.iCloudButton.enabled = NO;
        self.photoLibraryButton.enabled = NO;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator startAnimating];
        
        [self.recovery fetchAssetDatasWithCompletion:^(NSError *error) {
            
            self.iCloudButton.enabled = YES;
            self.photoLibraryButton.enabled = YES;
            [indicator stopAnimating];
            
            if (error) {
                [self alertErrorMessage:error.localizedDescription];
                return;
            }
            
            [self p_handleNext:nil];
        }];
    }
}

@end
