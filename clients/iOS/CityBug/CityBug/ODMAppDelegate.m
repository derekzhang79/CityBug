//
//  ODMAppDelegate.m
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMAppDelegate.h"
#import "ODMReport.h"

@implementation ODMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKObjectManager *shareObjManager = [RKObjectManager managerWithBaseURLString:@"http://localhost:3003"];
    shareObjManager.client.baseURL = [RKURL URLWithString:@"http://localhost:3003"];
    
    RKObjectMapping *reportMapping = [RKObjectMapping mappingForClass:[ODMReport class]];
    [reportMapping mapKeyPath:@"title" toAttribute:@"title"];
    [reportMapping mapKeyPath:@"note" toAttribute:@"note"];
    
    [shareObjManager.mappingProvider setMapping:reportMapping forKeyPath:@"entries"];
    
    return YES;
}

@end
