//
//  ODMDataManager.m
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManager.h"
#import <CoreData/CoreData.h>
#import "ODMEntry.h"
#import "ODMReport.h"
#import "ODMCategory.h"

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

static ODMDataManager *sharedDataManager = nil;

NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
NSString *ODMDataManagerNotificationCategoriesLoadingFail;



@interface ODMDataManager(Accessor)
/*
 * Read write access only DataManager
 */
@property (nonatomic, readwrite, strong) NSArray *categories, *reports;
@end

@implementation ODMDataManager

#pragma mark - Initialize

- (id)init
{
    if (self = [super init]) {
        //
        // Initialize Notification Identifier String
        //
        ODMDataManagerNotificationCategoriesLoadingFinish = @"ODMDataManagerNotificationCategoriesLoadingFinish";
        ODMDataManagerNotificationCategoriesLoadingFail = @"ODMDataManagerNotificationCategoriesLoadingFail";
        
        //
        // RestKit setup
        //
        serviceObjectManager = [RKObjectManager managerWithBaseURLString:BASE_URL];;
        
        //
        // Object Mapping
        //
        RKObjectMapping *reportMapping = [RKObjectMapping mappingForClass:[ODMReport class]];
        [reportMapping mapKeyPath:@"title" toAttribute:@"title"];
        [reportMapping mapKeyPath:@"note" toAttribute:@"note"];
        [reportMapping mapKeyPath:@"thumbnailImage" toAttribute:@"thumbnail_image"];
        
        [serviceObjectManager.mappingProvider addObjectMapping:reportMapping];
        [serviceObjectManager.mappingProvider setSerializationMapping:reportMapping forClass:[ODMReport class]];
        [serviceObjectManager.mappingProvider setMapping:reportMapping forKeyPath:@"reports"];
        
        //
        // Routing
        //
        [serviceObjectManager.router routeClass:[ODMReport class] toResourcePath:@"/api/reports" forMethod:RKRequestMethodPOST];
    }
    return self;
}

+ (ODMDataManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedDataManager == nil) {
            sharedDataManager = [[self alloc] init];
        }
    }
    return sharedDataManager;
}

/*
 * Method :GET
 */
- (NSArray *)getEntryList
{
    NSError *error;
    NSString *url = [BASE_URL stringByAppendingString:API_LIST];
      NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

    if (error) {
        ODMLog(@"error when get api %@ with error %@", [BASE_URL stringByAppendingString:API_LIST], error);
            return nil;
    }

    if (!data) {
        return nil;
    }

    return [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] objectForKey:@"entries"];
}

/*
 * CREATE REPORT
 * HTTP POST
 */
- (void)postNewReport:(ODMReport *)report
{
    RKParams *reportParams = [RKParams params];
    
    [[RKObjectManager sharedManager] postObject:report usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;
        
        [reportParams setValue:[report title] forParam:@"title"];
        [reportParams setValue:[report note] forParam:@"note"];
    
        NSData *fullImageData = UIImageJPEGRepresentation(report.fullImage, 1);
        NSData *thumbnailImageData = UIImageJPEGRepresentation(report.thumbnailImage, 1);
        
        [reportParams setData:fullImageData MIMEType:@"image/jpeg" forParam:@"full_image"];
        [reportParams setData:thumbnailImageData MIMEType:@"image/jpeg" forParam:@"thumbnail_image"];
        
        loader.params = reportParams;
    }];
}

#pragma mark - CATEGORY
/**
 * Category List
 */
- (NSArray *)categories
{
    if (categories_ == nil) {
        
        // Prototype Version using AlertView pop over when fetching category list
        
        UIAlertView *alertFetchingCategory = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CityBugTitleAlert", @"Title for alert dialog") message:NSLocalizedString(@"Waiting for connection", @"Waiting for connection") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button") otherButtonTitles:nil];
        
        [alertFetchingCategory show];
        
        [serviceObjectManager loadObjectsAtResourcePath:@"/api/categories" usingBlock:^(RKObjectLoader *loader){
            loader.onDidLoadObjects = ^(NSArray *objects){
                self.categories = [objects copy];
                
                // Post notification with category array
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationCategoriesLoadingFinish object:self.categories];
            };
        }];
    }
    
    ODMCategory *cat = [ODMCategory new]; cat.title = @"Human error";
    return [NSArray arrayWithObjects:cat, nil];
}

#pragma mark - RKObjectLoader Delegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    ODMLog(@"objectLoader %@", object);
    if ([objectLoader wasSentToResourcePath:@"/pet/uploadPhoto"]) {
        ODMReport *report = (ODMReport*)object;
        ODMLog(@"******* SEND report title %@", [report title]);
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    RKLogError(@"Loader Error %@", error);
}

@end
