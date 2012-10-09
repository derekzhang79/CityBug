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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:RKReachabilityWasDeterminedNotification object:nil];
    
    return YES;
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


@end
