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
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
    
    return YES;
}


@end
