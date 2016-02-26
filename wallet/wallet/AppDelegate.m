//
//  AppDelegate.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AppDelegate.h"
#import "DashboardViewController.h"
#import "LockScreenController.h"

#import "SystemManager.h"

@interface AppDelegate ()<LockScreenControllerDelegate>
@property (nonatomic, strong) UIWindow *lockScreenWindow;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // create window and root view controller
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor BTCCBlackColor];
    
    DashboardViewController *dashboardViewController = [[DashboardViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dashboardViewController];
    self.window.rootViewController = navigationController;
    
    // ui color
    [[UIButton appearance] setTitleColor:[UIColor BTCCPrimaryColor] forState:UIControlStateNormal];
    [[UILabel appearance] setTextColor:[UIColor BTCCBlackColor]];
    [[UITableView appearance] setSeparatorColor:[UIColor BTCCSeparatorColor]];
    self.window.tintColor = [UIColor BTCCPrimaryColor];
    
    // show
    [self.window makeKeyAndVisible];
    
    // and lock
    [self lockScreen];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self lockScreen];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Private Method
/// lock screen, check wallet to sign up or sign in
- (void)lockScreen {
    if (!_lockScreenWindow) {
        _lockScreenWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _lockScreenWindow.windowLevel = UIWindowLevelAlert;
    }
    
    LockScreenController *lockScreenController = [[LockScreenController alloc] init];
    lockScreenController.actionType = [[SystemManager defaultManager] checkWallet] ? LockScreenActionTypeSignIn : LockScreenActionTypeSignUp;
    lockScreenController.delegate = self;
    self.lockScreenWindow.rootViewController = lockScreenController;
    
    [self.lockScreenWindow makeKeyAndVisible];
}
/// unlock
- (void)unlockScreen {
    [UIView animateWithDuration:.3 animations:^{
        self.lockScreenWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [self.lockScreenWindow resignKeyWindow];
        self.lockScreenWindow = nil;
    }];
}

#pragma mark - LockScreenControllerDelegate
- (void)lockScreenController:(LockScreenController *)controller didUnlockWithActionType:(LockScreenActionType)type {
    // TODO: route action type
    
    // unlock
    [self unlockScreen];
}

@end
