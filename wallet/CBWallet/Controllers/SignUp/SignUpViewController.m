//
//  SignUpViewController.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignUpMasterPasswordViewController.h"
#import "SignUpSettingsViewController.h"

#import "InversedSolidButton.h"

#import "CBWRecovery.h"
#import "Guard.h"
#import "Database.h"

#import "SSKeychain.h"
#import "AESCrypt.h"

#import "UIViewController+AlertMessage.h"

typedef NS_ENUM(NSUInteger, kSignUpViewControllerStep) {
    kSignUpViewControllerStepWelcome,
    kSignUpViewControllerStepMasterPassword,
    kSignUpViewControllerStepSettings
};

typedef NS_ENUM(NSUInteger, kSignUpViewControllerAction) {
    kSignUpViewControllerActionCreate,
    kSignUpViewControllerActionRecover
};

static const CGFloat kSignUpViewControllerTitleLabelHeight = 40.f;
static const CGFloat kSignUpViewControllerDescriptionLabelHeight = 25.f;
static const CGFloat kSignUpViewControllerTitleBottomMargin = 10.f;

@interface SignUpViewController ()<SignUpMasterPasswordViewControllerDelegate, SignUpSettingsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *descriptionLabel;
@property (nonatomic, weak) UIView *welcomeView;
@property (nonatomic, weak) UIView *recoverView;
@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UIButton *backButton;

@property (nonatomic, strong) SignUpMasterPasswordViewController *masterPasswordViewController;
@property (nonatomic, strong) SignUpSettingsViewController *settingsViewController;

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *hint;

@property (nonatomic, assign) kSignUpViewControllerStep step;
@property (nonatomic, assign) kSignUpViewControllerAction action;

@property (nonatomic, strong) CBWRecovery *recovery;

@end

@implementation SignUpViewController

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame) * 2, CGRectGetHeight(scrollView.frame));
        scrollView.pagingEnabled = YES;
        scrollView.scrollEnabled = NO;
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, HD_IMAGE_PORTRAIT_HEIGHT, scrollView.contentSize.width, scrollView.contentSize.height - HD_IMAGE_PORTRAIT_HEIGHT)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:backgroundView];
        [self.view addSubview:scrollView];
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        // back button
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, CBWLayoutCommonPadding * 2 + 24, 44)];
        backButton.tintColor = [UIColor CBWWhiteColor];
        [backButton setImage:[[UIImage imageNamed:@"navigation_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        backButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
        backButton.alpha = 0;
        backButton.hidden = YES;
        [backButton addTarget:self action:@selector(p_handleBack) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backButton];
        _backButton = backButton;
    }
    return _backButton;
}

- (UIView *)recoverView {
    if (!_recoverView) {
        CGFloat height = SCREEN_HEIGHT_GOLDEN_SMALL + CBWCellHeightDefault;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - height, SCREEN_WIDTH, height)];
        view.alpha = 0;
        view.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT_GOLDEN_SMALL);
        [self.view addSubview:view];
        _recoverView = view;
        
        CGFloat padding = CBWLayoutCommonPadding;
        
        // iCloud button
        InversedSolidButton *iCloudButton = [[InversedSolidButton alloc] initWithFrame:CGRectMake(padding, 0, SCREEN_WIDTH - 2 * padding, CBWCellHeightDefault)];
        [iCloudButton setTitle:NSLocalizedStringFromTable(@"Button recover_from_icloud", @"CBW", nil) forState:UIControlStateNormal];
        [iCloudButton addTarget:self action:@selector(p_handleFetchiCloudData) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:iCloudButton];
        
        // photo library button
        InversedSolidButton *photoLibraryButton = [[InversedSolidButton alloc] initWithFrame:CGRectOffset(iCloudButton.frame, 0, CBWCellHeightDefault + padding)];
        [photoLibraryButton setTitle:NSLocalizedStringFromTable(@"Button photo_library", @"CBW", nil) forState:UIControlStateNormal];
        [photoLibraryButton addTarget:self action:@selector(p_handleOpenPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:photoLibraryButton];
        
        // recover button
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectOffset(iCloudButton.frame, 0, SCREEN_HEIGHT_GOLDEN_SMALL - padding)];
        [backButton setTitle:NSLocalizedStringFromTable(@"Button back", @"CBW", nil) forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(p_dismissRecover) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:backButton];
    }
    return _recoverView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // background
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed:@"background"];
    [self.view addSubview:background];
    
    CGFloat padding = CBWLayoutCommonPadding;
    
    // title
    UIFont *titleFont = [UIFont systemFontOfSize:32.f weight:UIFontWeightThin];
    NSString *title = NSLocalizedStringFromTable(@"Title welcome", @"CBW", nil);
    CGFloat titleWidth = [title sizeWithFont:titleFont maxSize:CGSizeMake(SCREEN_WIDTH - 2 * padding, kSignUpViewControllerTitleLabelHeight)].width;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - titleWidth) / 2.f, SCREEN_HEIGHT_GOLDEN_SMALL - kSignUpViewControllerDescriptionLabelHeight - kSignUpViewControllerTitleBottomMargin - kSignUpViewControllerTitleLabelHeight, titleWidth, kSignUpViewControllerTitleLabelHeight)];
    titleLabel.font = titleFont;
    titleLabel.textColor = [UIColor CBWWhiteColor];
    titleLabel.text = title;
    [self.view addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    // description
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(titleLabel.frame) + kSignUpViewControllerTitleBottomMargin, SCREEN_WIDTH - 2 * padding, kSignUpViewControllerDescriptionLabelHeight)];
    descriptionLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize] weight:UIFontWeightThin];
    descriptionLabel.textColor = [UIColor CBWWhiteColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.text = NSLocalizedStringFromTable(@"Description welcome", @"CBW", nil);
    [self.view addSubview:descriptionLabel];
    _descriptionLabel = descriptionLabel;
    
    // welcome view
    CGFloat welcomeHeight = SCREEN_HEIGHT_GOLDEN_SMALL + CBWCellHeightDefault;
    UIView *welcomeView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - welcomeHeight, SCREEN_WIDTH, welcomeHeight)];
    [self.view addSubview:welcomeView];
    _welcomeView = welcomeView;
    
    // create button
    InversedSolidButton *createButton = [[InversedSolidButton alloc] initWithFrame:CGRectMake(padding, 0, SCREEN_WIDTH - 2 * padding, CBWCellHeightDefault)];
    [createButton setTitle:NSLocalizedStringFromTable(@"Button create_wallet", @"CBW", nil) forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(p_handleNewWallet) forControlEvents:UIControlEventTouchUpInside];
    [welcomeView addSubview:createButton];
    
    // recover button
    UIButton *recoverButton = [[UIButton alloc] initWithFrame:CGRectOffset(createButton.frame, 0, SCREEN_HEIGHT_GOLDEN_SMALL - padding)];
    [recoverButton setTitle:NSLocalizedStringFromTable(@"Button recover_wallet", @"CBW", nil) forState:UIControlStateNormal];
    [recoverButton addTarget:self action:@selector(p_presentRecover) forControlEvents:UIControlEventTouchUpInside];
    [welcomeView addSubview:recoverButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DLog(@"sign up dealloc!");
}


#pragma mark - Private Method

- (void)p_handleNewWallet {
    DLog(@"handle new wallet");
    
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        if (self.action == kSignUpViewControllerActionRecover) {
            self.recoverView.alpha = 0;
            self.recoverView.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT_GOLDEN_SMALL);
        } else {
            self.welcomeView.alpha = 0;
            self.welcomeView.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT_GOLDEN_SMALL);
            self.descriptionLabel.alpha = 0;
        }
    }];
    
    [self p_goToMasterPassword];
}

- (void)p_backToWelcome {
    
    self.step = kSignUpViewControllerStepWelcome;
    
    CGFloat titleWidth = self.action == kSignUpViewControllerActionRecover ? CGRectGetWidth(self.titleLabel.frame) : [self p_transformTitle:NSLocalizedStringFromTable(@"Title welcome", @"CBW", nil) delay:0].width;
    
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        if (self.action == kSignUpViewControllerActionRecover) {
            self.recoverView.alpha = 1;
            self.recoverView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - titleWidth) / 2.f, SCREEN_HEIGHT_GOLDEN_SMALL - kSignUpViewControllerDescriptionLabelHeight - kSignUpViewControllerTitleBottomMargin - kSignUpViewControllerTitleLabelHeight, titleWidth, kSignUpViewControllerTitleLabelHeight);
        } else {
            self.welcomeView.alpha = 1;
            self.welcomeView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.descriptionLabel.alpha = 1;
            self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - titleWidth) / 2.f, SCREEN_HEIGHT_GOLDEN_SMALL - kSignUpViewControllerDescriptionLabelHeight - kSignUpViewControllerTitleBottomMargin - kSignUpViewControllerTitleLabelHeight, titleWidth, kSignUpViewControllerTitleLabelHeight);
        }
        
        self.scrollView.frame = CGRectOffset(self.scrollView.frame, 0, CGRectGetHeight(self.scrollView.frame));
        self.backButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.backButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.backButton.hidden = YES;
        
        [self.scrollView scrollRectToVisible:self.masterPasswordViewController.view.frame animated:NO];
        
        [self.masterPasswordViewController.view removeFromSuperview];
        [self.masterPasswordViewController removeFromParentViewController];
        self.masterPasswordViewController = nil;
        
        self.password = nil;
        self.hint = nil;
        
        [self.settingsViewController.view removeFromSuperview];
        [self.settingsViewController removeFromParentViewController];
        self.settingsViewController = nil;
    }];
    
}

- (void)p_goToMasterPassword {
    
    self.step = kSignUpViewControllerStepMasterPassword;
    
    if (!self.masterPasswordViewController) {
        self.masterPasswordViewController = [[SignUpMasterPasswordViewController alloc] init];
        self.masterPasswordViewController.delegate = self;
        if (self.action == kSignUpViewControllerActionRecover) {
            self.masterPasswordViewController.recoverEnabled = YES;
            self.masterPasswordViewController.hint = self.recovery.hint;
        }
        [self addChildViewController:self.masterPasswordViewController];
        [self.scrollView addSubview:self.masterPasswordViewController.view];
    }
    
    self.backButton.hidden = NO;
    self.scrollView.frame = CGRectOffset(self.scrollView.frame, 0, CGRectGetHeight(self.scrollView.frame));
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        self.backButton.alpha = 1;
        
        self.titleLabel.frame = CGRectMake(CBWLayoutCommonPadding, HD_IMAGE_PORTRAIT_HEIGHT * 0.618 - kSignUpViewControllerTitleLabelHeight / 2.f, CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        self.scrollView.frame = self.view.bounds;
    }];
    
    if (self.action != kSignUpViewControllerActionRecover) {
        [self p_transformTitle:NSLocalizedStringFromTable(@"Title new", @"CBW", nil) delay:CBWAnimateDuration - CBWAnimateDurationFast];
    }
}

- (void)p_backToMasterPasswoerd {
    
    self.step = kSignUpViewControllerStepMasterPassword;
    
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        self.backButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }];
    
    [self p_transformTitle:(self.action == kSignUpViewControllerActionRecover ? NSLocalizedStringFromTable(@"Title recover", @"CBW", nil) :  NSLocalizedStringFromTable(@"Title new", @"CBW", nil)) delay:0];
    
    [self.scrollView scrollRectToVisible:self.masterPasswordViewController.view.frame animated:YES];
    
}

- (void)p_goToSettings {
    
    self.step = kSignUpViewControllerStepSettings;
    
    if (!self.settingsViewController) {
        self.settingsViewController = [[SignUpSettingsViewController alloc] init];
        self.settingsViewController.delegate = self;
        [self addChildViewController:self.settingsViewController];
        [self.scrollView addSubview:self.settingsViewController.view];
        self.settingsViewController.view.frame = CGRectOffset(self.settingsViewController.view.frame, CGRectGetWidth(self.scrollView.frame), 0);
    }
    
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        self.backButton.transform = CGAffineTransformMakeRotation(0);
    }];
    
    [self p_transformTitle:NSLocalizedStringFromTable(@"Title settings", @"CBW", nil) delay:0];
    
    [self.scrollView scrollRectToVisible:self.settingsViewController.view.frame animated:YES];
}

- (void)p_presentRecover {
    self.action = kSignUpViewControllerActionRecover;
    
    CGSize oldTitleSize = self.titleLabel.frame.size;
    CGSize titleSize = [self p_transformTitle:NSLocalizedStringFromTable(@"Title recover", @"CBW", nil) delay:0];
    
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, (oldTitleSize.width - titleSize.width) / 2.f, 0);
        self.welcomeView.alpha = 0;
        self.welcomeView.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT_GOLDEN_SMALL);
        self.descriptionLabel.alpha = 0;
        
        self.recoverView.alpha = 1;
        self.recoverView.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        [self.view bringSubviewToFront:self.recoverView];
    }];
    
}

- (void)p_dismissRecover {
    self.action = kSignUpViewControllerActionCreate;
    
    CGSize oldTitleSize = self.titleLabel.frame.size;
    CGSize titleSize = [self p_transformTitle:NSLocalizedStringFromTable(@"Title welcome", @"CBW", nil) delay:0];
    
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, (oldTitleSize.width - titleSize.width) / 2.f, 0);
        self.welcomeView.alpha = 1;
        self.welcomeView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.descriptionLabel.alpha = 1;
        
        self.recoverView.alpha = 0;
        self.recoverView.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT_GOLDEN_SMALL);
    } completion:^(BOOL finished) {
        [self.view bringSubviewToFront:self.welcomeView];
    }];
    
}

- (CGSize)p_transformTitle:(NSString *)title delay:(NSTimeInterval)delay {
    CGSize size = [title sizeWithFont:self.titleLabel.font maxSize:CGSizeMake(SCREEN_WIDTH - 2 * CBWLayoutCommonPadding, kSignUpViewControllerTitleLabelHeight)];
    [UIView animateWithDuration:CBWAnimateDurationFast delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.titleLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.titleLabel.text = title;
        CGRect frame = self.titleLabel.frame;
        frame.size = size;
        self.titleLabel.frame = frame;
        [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
            self.titleLabel.alpha = 1;
        }];
    }];
    return size;
}

- (void)p_handleBack {
    switch (self.step) {
        case kSignUpViewControllerStepSettings: {
            [self p_backToMasterPasswoerd];
            break;
        }
        case kSignUpViewControllerStepMasterPassword: {
            [self p_backToWelcome];
            break;
        }
        default:
            break;
    }
}

- (void)p_createWallet {
    DLog(@"create wallet");
    // create seed
    NSString *seed = [NSString randomStringWithLength:64];
    // encrypt seed with key
    NSString *encryptedSeed = [AESCrypt encrypt:seed password:self.password];
    
    if (!encryptedSeed) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Failed", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message create_wallet_failed", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (!self.hint) {
        NSLog(@"create wallet without hint");
        self.hint = @"";
    }
    
    // create
    NSString *base64Hint = [[self.hint dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSArray *seedAndHint = @[encryptedSeed, base64Hint];
    CBWRecovery *recovery = [[CBWRecovery alloc] initWithDatas:@[seedAndHint, [CBWRecovery defaultAccountItemsDictionary]]];
    if ([recovery recoverWithCode:self.password]) {
        // success
        // notification
        [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationWalletCreated object:nil];
        // thank you, go
        [self.delegate SignUpViewControllerDidComplete:self];
        
    } else {
        // fail
        [self alertMessage:NSLocalizedStringFromTable(@"Alert Message invalid_master_password", @"CBW", nil) withTitle:NSLocalizedStringFromTable(@"Failed", @"CBW", nil)];
    };
}

- (BOOL)p_recoverWallet {
    DLog(@"recover wallet");
    if ([self.recovery recoverWithCode:self.password]) {
        // notification
        [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationWalletRecovered object:nil];
        // thank you, go
        return YES;
    }
    [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message invalid_master_password", @"CBW", nil)];
    return NO;
}

- (void)p_handleFetchiCloudData {
    self.recoverView.alpha = 0.5;
    self.recoverView.userInteractionEnabled = NO;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    self.recovery = [[CBWRecovery alloc] init];
    [self.recovery fetchCloudKitDataWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.recoverView.alpha = 1;
            self.recoverView.userInteractionEnabled = YES;
            [indicator stopAnimating];
            
            if (error) {
                [self alertMessage:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil)];
            } else {
                [self p_handleNewWallet];
            }
        });
    }];
}

- (void)p_handleOpenPhotoLibrary {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - <SignUpMasterPasswordViewControllerDelegate>
- (void)signUpMasterPasswordViewController:(SignUpMasterPasswordViewController *)vc didInputPassword:(NSString *)password andHint:(NSString *)hint {
    DLog(@"input password: %@, hint: %@", password, hint);
    
    self.password = [password copy];
    self.hint = [hint copy];
    
    if (self.action == kSignUpViewControllerActionRecover) {
        if ([self p_recoverWallet]) {
            [self p_goToSettings];
        }
    } else {
        [self p_goToSettings];
    }
}

#pragma mark - <SignUpSettingsViewController>
- (void)signUpSettingsViewControllerDidComplete:(SignUpSettingsViewController *)vc {
    DLog(@"complete settings");
    if (self.action == kSignUpViewControllerActionRecover) {
        [self.delegate SignUpViewControllerDidComplete:self];
    } else {
        [self p_createWallet];
    }
}

#pragma mark - <UIImagePickerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    
    self.recovery = [[CBWRecovery alloc] initWithAssetURL:url];
    if (self.recovery) {
        
        self.recoverView.alpha = 0.5;
        self.recoverView.userInteractionEnabled = NO;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator startAnimating];
        
        [self.recovery fetchAssetDatasWithCompletion:^(NSError *error) {
            
            self.recoverView.alpha = 1;
            self.recoverView.userInteractionEnabled = YES;
            [indicator stopAnimating];
            
            if (error) {
                
                if ([self.recovery hasSeed]) {
                    // 有 seed 数据
                    [self p_handleNewWallet];
                } else {
                    [self alertErrorMessage:error.localizedDescription];
                }
                
                return;
            }
            
            [self p_handleNewWallet];
        }];
    }
}

@end
