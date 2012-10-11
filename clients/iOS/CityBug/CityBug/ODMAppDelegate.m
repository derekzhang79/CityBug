//
//  ODMAppDelegate.m
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMAppDelegate.h"
#import "ODMReport.h"
#import "ODMDataManager.h"

@implementation ODMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLogConfigureByName("RestKit/Network*", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:RKReachabilityDidChangeNotification object:nil];
    
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    tabController.delegate = self;
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"TAB!!! %@", viewController.title);
    NSString *tabNumber = @"0";
    
    if ([viewController.title isEqualToString:TAB_PROFILE_TITLE]) {
        return;
    } else if ([viewController.title isEqualToString:TAB_FEED_TITLE]) {
        tabNumber = @"0";
    } else if ([viewController.title isEqualToString:TAB_EXPLORE_TITLE]) {
        tabNumber = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:tabNumber forKey:NOW_TABBAR];
}

- (void)reachabilityStatusChanged:(NSNotification *)notification
{

    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    if ([[[RKClient sharedClient] reachabilityObserver] isReachabilityDetermined] && [[RKClient sharedClient] isNetworkReachable]) {
        NSLog(@"Internet reachable");
    } else {
        NSLog(@"Internet not reachable");

        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                     message: NSLocalizedString(@"No internet connection found, this application requires an internet connection to gather the data required.", @"Network error")
                     delegate: self
                     cancelButtonTitle: NSLocalizedString(@"Close", @"Network error") otherButtonTitles: nil];
        
        [errorView show];
    }
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self reachabilityStatusChanged:nil];
}

@end
