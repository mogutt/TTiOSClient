//
//  DDAppDelegate.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//
// hunshou modify

#import "DDAppDelegate.h"
#import "LoginViewController.h"
#import "DDClientState.h"
#import "ChattingMainViewController.h"
#import "RuntimeStatus.h"

#import "DDClientStateMaintenanceManager.h"
#import "std.h"
@implementation DDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //test
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [RuntimeStatus instance];
    LoginViewController* loginViewController = [LoginViewController new];

    self.window.rootViewController = loginViewController;
    [self.window makeKeyAndVisible];
    
//    [MGJApp registerApp:@"mgj" type:@"iPhone" channel:@"NIMDEV" version:560 apiHost:@"www.mogujie.com" apiBasePath:[NSString stringWithFormat:@"app_mgj_v%d_", 560] enncryptionToken:@"mgj@xiangang" appleId:@"452176796"];

   
//=======
//    [self.window makeKeyAndVisible];
//    
//    DDLoginViewController* loginViewController = [DDLoginViewController new];
//    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//    [self.window setRootViewController:navigationController];
//
//>>>>>>> 5e49de23fb7c447ababd4d76ac6b7c244770d39d
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DDClientState* clientState = [DDClientState shareInstance];
    [clientState setUseStateWithoutObserver:DDUserOffLine];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDClientState* clientState = [DDClientState shareInstance];
    [clientState setUseStateWithoutObserver:DDUserOffLine];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    if ([RuntimeStatus instance].user.userId !=nil) {
        DDClientState* clientState = [DDClientState shareInstance];
        clientState.userState=DDUserOffLine;
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
