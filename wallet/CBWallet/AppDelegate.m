//
//  AppDelegate.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AppDelegate.h"
#import "AccountViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"

#import "Installation.h"
#import "SystemManager.h"
#import "Guard.h"

@interface AppDelegate ()<SignInViewControllerDelegate, SignUpViewControllerDelegate>
@property (nonatomic, strong) UIWindow *lockScreenWindow;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Installation launchWithCompletion:^(BOOL needUpdate, BOOL success) {
        NSLog(@"need update? %d, update success? %d", needUpdate, success);
    }];
    
    // create window and root view controller
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor CBWBlackColor];
    
    AccountViewController *accountViewController = [[AccountViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
    self.window.rootViewController = navigationController;
    
    // ui color
    [[UILabel appearance] setTextColor:[UIColor CBWTextColor]];
//    [[UIButton appearance] setTitleColor:[UIColor CBWPrimaryColor] forState:UIControlStateNormal];
//    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class]]] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [[UIButton appearance] setTitleColor:[[UIColor CBWPrimaryColor] colorWithAlphaComponent:CBWDisabledOpacity] forState:UIControlStateDisabled];
    [[UITextField appearance] setTextColor:[UIColor CBWTextColor]];
    [[UITableView appearance] setSeparatorColor:[UIColor CBWSeparatorColor]];
    self.window.tintColor = [UIColor CBWPrimaryColor];
    
    // show
    [self.window makeKeyAndVisible];
    
    // and lock
    [self lockScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockScreen) name:CBWNotificationCheckedOut object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[Guard globalGuard] checkOut];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    UIViewController *lockScreenViewController = self.lockScreenWindow.rootViewController;
    if ([lockScreenViewController isKindOfClass:[SignInViewController class]]) {
        [((SignInViewController *)lockScreenViewController) showKeyboard];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Private Method
/// lock screen, check wallet to sign up or sign in
- (void)lockScreen {
    if (!_lockScreenWindow) {
        _lockScreenWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    if (!self.lockScreenWindow.rootViewController) {
        if ([[SystemManager defaultManager] isWalletInstalled]) {
            SignInViewController *signInViewController = [[SignInViewController alloc] init];
            signInViewController.delegate = self;
            self.lockScreenWindow.rootViewController = signInViewController;
        } else{
            SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
            signUpViewController.delegate = self;
            self.lockScreenWindow.rootViewController = signUpViewController;
        }
    }
    
    self.lockScreenWindow.windowLevel = UIWindowLevelAlert;// overlay on the status bar
    [self.lockScreenWindow makeKeyAndVisible];
}
/// unlock
- (void)unlockScreen {
    [UIView animateWithDuration:CBWAnimateDuration animations:^{
        self.lockScreenWindow.rootViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.lockScreenWindow.windowLevel = UIWindowLevelNormal;
            self.lockScreenWindow.rootViewController = nil;
            [self.lockScreenWindow resignKeyWindow];
            [self.window makeKeyAndVisible];
        }
    }];
}

#pragma mark - <SignInViewControllerDelegate>
- (void)signInViewControllerDidUnlock:(SignInViewController *)vc {
    [self unlockScreen];
}

#pragma mark - <SignUpViewControllerDelegate>
- (void)SignUpViewControllerDidComplete:(SignUpViewController *)vc {
    [self unlockScreen];
}

@end
