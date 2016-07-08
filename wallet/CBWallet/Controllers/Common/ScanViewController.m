//
//  ScanViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) UIView *laser;
@property (nonatomic, weak) UIView *cameraView;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ScanViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    if (self.navigationController) {
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(p_dismiss:)];
        closeButtonItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = closeButtonItem;
    } else {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20.f, 60.f, 44.f)];
        [closeButton addTarget:self action:@selector(p_dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setImage:[[UIImage imageNamed:@"navigation_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        closeButton.tintColor = [UIColor whiteColor];
        [self.view addSubview:closeButton];
    }
    
    CGFloat width = roundf(SCREEN_WIDTH * 0.75);
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - width) / 2, (SCREEN_HEIGHT - width) / 2, width, width)];
    whiteView.backgroundColor = [UIColor whiteColor];
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [maskView addSubview:whiteView];
    
    CGRect laserFrame = whiteView.frame;
    laserFrame.size.height = 1;
    UIView *laser = [[UIView alloc] initWithFrame:laserFrame];
    laser.backgroundColor = [UIColor greenColor];
    laser.hidden = YES;
    [self.view addSubview:laser];
    _laser = laser;
    
    UIView *cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:cameraView atIndex:0];
    cameraView.maskView = maskView;
    _cameraView = cameraView;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(whiteView.frame) + CBWLayoutCommonVerticalPadding, CGRectGetWidth(self.view.frame), 20.f)];
    tipLabel.font = [UIFont systemFontOfSize:UIFont.labelFontSize];
    tipLabel.textColor = [UIColor CBWMutedTextColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = NSLocalizedStringFromTable(@"Tip scan_qrcode", @"CBW", nil);
    [self.view insertSubview:tipLabel aboveSubview:cameraView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self p_startReading];
    
    if (self.laser.hidden) {
        self.laser.hidden = NO;
        CAKeyframeAnimation *scanningAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
        scanningAnimation.values = @[@0, @(CGRectGetWidth(self.laser.frame))];
        scanningAnimation.calculationMode = kCAAnimationCubic;
        scanningAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        scanningAnimation.duration = CBWAnimateDUrationSlow * 2;
        scanningAnimation.repeatCount = HUGE_VALF;
        scanningAnimation.additive = YES;
        [self.laser.layer addAnimation:scanningAnimation forKey:@"scanning"];
    }
}

#pragma mark - Private Method

#pragma mark Handlers
- (void)p_dismiss:(id)sender {
    if ([self.delegate respondsToSelector:@selector(scanViewControllerWillDismiss:)]) {
        [self.delegate scanViewControllerWillDismiss:self];
        return;
    }
    
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Read QR Code
- (BOOL)p_startReading {
    
    NSError *error;
    // device
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // input
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (!deviceInput) {
        return NO;
    }
    
    // output
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    // session
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:deviceInput];
    [_captureSession addOutput:captureMetadataOutput];
    
    // queue & delegate & types
    dispatch_queue_t dispatch_queue;
    dispatch_queue = dispatch_queue_create("captureOutputQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_queue];// delegate
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];// types, need in queue
    
    // previewLayer
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:_cameraView.layer.bounds];
    [_previewLayer setBackgroundColor:[UIColor CBWBlackColor].CGColor];
    [_cameraView.layer addSublayer:_previewLayer];
    
    // start
    [_captureSession startRunning];
    _isReading = YES;
    
    return YES;
}
- (void)p_stopReading {
    if (!_isReading) {
        return;
    }
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_previewLayer removeFromSuperlayer];
    _previewLayer = nil;
    
    _isReading = NO;
}

- (void)p_didReadString:(NSString *)string {
    DLog(@"scan read: %@", string);
    
    if (self.delegate) {
        [self.delegate scanViewController:self didScanString:string];
    }
    [self p_soundEffect];
}

- (void)p_soundEffect {
//    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/begin_video_record.caf"];
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
//    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        [self performSelectorOnMainThread:@selector(p_stopReading) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(p_didReadString:) withObject:[metadataObj stringValue] waitUntilDone:NO];
    }
}

@end
