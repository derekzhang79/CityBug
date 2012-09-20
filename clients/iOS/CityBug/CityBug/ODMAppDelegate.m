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
    // you can chang "BASE_URL" to 
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURLString:BASE_URL];
    objectManager.client.baseURL = [RKURL URLWithString:BASE_URL];
    
    RKObjectMapping *reportMapping = [RKObjectMapping mappingForClass:[ODMReport class]];
    [reportMapping mapKeyPath:@"title" toAttribute:@"title"];
    [reportMapping mapKeyPath:@"note" toAttribute:@"note"];
    [reportMapping mapKeyPath:@"thumbnailImage" toAttribute:@"thumbnail_image"];
    
    [objectManager.mappingProvider addObjectMapping:reportMapping];
    [objectManager.mappingProvider setSerializationMapping:reportMapping forClass:[ODMReport class]];
    [objectManager.mappingProvider setMapping:reportMapping forKeyPath:@"reports"];
    
    [objectManager.router routeClass:[ODMReport class] toResourcePath:@"/api/reports" forMethod:RKRequestMethodPOST];
    return YES;
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    ODMLog(@"error %@", error);
}

@end
