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
//    PrimaryButton *iCloudButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f, stageWidth - 40.f, CBWCellHeightDefault)];
//    [iCloudButton addTarget:self action:@selector(p_handleNext:) forControlEvents:UIControlEventTouchUpInside];
//    [iCloudButton setTitle:NSLocalizedStringFromTable(@"Button iCloud", @"CBW", nil) forState:UIControlStateNormal];
//    [self.view addSubview:iCloudButton];
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

- (void)p_handleOpenPhotoLibrary:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)p_decode {
    
    // test
//    DLog(@"asset url: %@", assetURL.absoluteString);
//    
//    // 解码
//    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
//        ALAssetRepresentation *representation = myasset.defaultRepresentation;
//        long long size = representation.size;
//        NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:size];
//        void *buffer = [rawData mutableBytes];
//        [representation getBytes:buffer fromOffset:0 length:size error:nil];
//        NSData *apngData = [[NSData alloc] initWithBytes:buffer length:size];
//        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:apngData scale:2.f];
//        UIImage *seedImage = [decoder frameAtIndex:0 decodeForDisplay:NO].image;
//        
//        // 获取二维码
//        CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:nil] options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
//        if (detector) {
//            DLog(@"detector ready");
//            CIImage *ciimg = [CIImage imageWithCGImage:seedImage.CGImage];
//            NSArray *featuresR = [detector featuresInImage:ciimg];
//            
//            for (CIQRCodeFeature* featureR in featuresR) {
//                DLog(@"decode: %@ ", featureR.messageString);
//            }
//        }
//    };
//    
//    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
//        DLog(@"booya, cant get image - %@",[myerror localizedDescription]);
//    };
//    
//    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
//    [assetLibrary assetForURL:assetURL
//                  resultBlock:resultblock
//                 failureBlock:failureblock];
    
    
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
