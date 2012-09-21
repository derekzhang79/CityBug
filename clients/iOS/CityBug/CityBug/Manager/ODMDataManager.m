//
//  ODMDataManager.m
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManager.h"

#import "ODMReport.h"
#import "ODMCategory.h"
#import "ODMPlace.h"
#import "ODMUser.h"

static ODMDataManager *sharedDataManager = nil;

NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
NSString *ODMDataManagerNotificationCategoriesLoadingFail;



@interface ODMDataManager(Accessor)
/*
 * Read write access only DataManager
 */
@property (nonatomic, readwrite, strong) NSArray *categories, *reports, *places;
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
        serviceObjectManager = [RKObjectManager managerWithBaseURLString:BASE_URL];
        serviceObjectManager.client.username = @"admin";
        serviceObjectManager.client.password = @"1q2w3e4r";
//        serviceObjectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
        serviceObjectManager.client.defaultHTTPEncoding = NSUTF8StringEncoding;
        
        //
        // Object Mapping
        //
        RKObjectMapping *reportMapping = [RKObjectMapping mappingForClass:[ODMReport class]];
        [reportMapping mapKeyPath:@"title" toAttribute:@"title"];
        [reportMapping mapKeyPath:@"note" toAttribute:@"note"];
        [reportMapping mapKeyPath:@"thumbnail_image" toAttribute:@"thumbnailImage"];
        [reportMapping mapKeyPath:@"full_image" toAttribute:@"fullImage"];
        [reportMapping mapKeyPath:@"lat" toAttribute:@"latitude"];
        [reportMapping mapKeyPath:@"lng" toAttribute:@"longitude"];
        [serviceObjectManager.mappingProvider addObjectMapping:reportMapping];
        [serviceObjectManager.mappingProvider setMapping:reportMapping forKeyPath:@"reports"];
        
        RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[ODMCategory class]];
        [categoryMapping mapKeyPath:@"title" toAttribute:@"title"];
        
        RKObjectMapping *placeMapping = [RKObjectMapping mappingForClass:[ODMPlace class]];
        [placeMapping mapKeyPath:@"title" toAttribute:@"title"];
        [placeMapping mapKeyPath:@"lat" toAttribute:@"latitude"];
        [placeMapping mapKeyPath:@"lng" toAttribute:@"longitude"];

        RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[ODMUser class]];
        [userMapping mapAttributes:@"username", @"email", @"password", nil];
        [userMapping mapKeyPath:@"_id" toAttribute:@"uid"];
        
        // Mapping Relation
//        [reportMapping mapKeyPath:@"categories" toRelationship:@"categories" withMapping:categoryMapping];
        [reportMapping mapRelationship:@"categories" withMapping:categoryMapping];
        [reportMapping mapRelationship:@"place" withMapping:placeMapping];
        [reportMapping mapRelationship:@"user" withMapping:userMapping];
        
        [serviceObjectManager.mappingProvider setMapping:reportMapping forKeyPath:@"reports"];
        [serviceObjectManager.mappingProvider setMapping:categoryMapping forKeyPath:@"categories"];
        [serviceObjectManager.mappingProvider setMapping:placeMapping forKeyPath:@"place"];
        [serviceObjectManager.mappingProvider setMapping:userMapping forKeyPath:@"user"];
        
        // Serialization
        [serviceObjectManager.mappingProvider setSerializationMapping:[reportMapping inverseMapping] forClass:[ODMReport class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:categoryMapping forClass:[ODMCategory class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:placeMapping forClass:[ODMPlace class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:userMapping forClass:[ODMUser class]];
        
        // Routing
        [serviceObjectManager.router routeClass:[ODMReport class] toResourcePath:@"/api/reports" forMethod:RKRequestMethodPOST];
        [serviceObjectManager.router routeClass:[ODMCategory class] toResourcePath:@"/api/categories" forMethod:RKRequestMethodGET];
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
    
    ODMUser *admin = [ODMUser newUser:@"admin" email:@"admin@opendream.co.th" password:@"1234qwer"];
    report.user = admin;
    
    [[RKObjectManager sharedManager] postObject:report usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;
        
        [reportParams setValue:[report title]     forParam:@"title"];
        [reportParams setValue:[report note]      forParam:@"note"];
        [reportParams setValue:[report latitude]  forParam:@"lat"];
        [reportParams setValue:[report longitude] forParam:@"lng"];
        [reportParams setValue:[report.user username] forParam:@"username"];

        NSArray *catItems = [report.categories valueForKeyPath:@"title"];
        [reportParams setValue:catItems forParam:@"categories"];
        
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
    if (!categories_) {
        
        [serviceObjectManager loadObjectsAtResourcePath:@"/api/categories" usingBlock:^(RKObjectLoader *loader){
            loader.objectMapping = [serviceObjectManager.mappingProvider serializationMappingForClass:[ODMCategory class]];
            loader.onDidLoadObjects = ^(NSArray *objects){
                categories_ = [objects copy];
                
                // Post notification with category array
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationCategoriesLoadingFinish object:self.categories];
            };
        }];
    }
    
    ODMCategory *cat = [ODMCategory new]; cat.title = @"Human error";
    return [NSArray arrayWithObjects:cat, nil];
}

#pragma mark - PLACE
/**
 * Place list
 */
- (NSArray *)places
{
    if (!places_) {
        
        NSDictionary *queryParams = [NSDictionary dictionaryWithKeysAndObjects:@"lat", @"10.33023",
                                     @"lng", @"133.324523", nil];
        NSString *resourcePath = [@"/api/place/search" stringByAppendingQueryParameters:queryParams];
        
        [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
            loader.onDidLoadObjects = ^(NSArray *objects){
                places_ = [objects copy];
                
                // Post notification with category array
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationCategoriesLoadingFinish object:self.places];
            };
        }];
    }
    
    ODMPlace *place1 = [[ODMPlace alloc] init];
    place1.title = @"Opendream@BKK";
    place1.latitude = @13.791343;
    place1.longitude = @100.587473;
    
    ODMPlace *place2 = [[ODMPlace alloc] init];
    place2.title = @"Opendream@CHX";
    place2.latitude = @13.791343;
    place2.longitude = @100.587473;
    
    NSDictionary *sectionA = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:place1, nil], @"suggestion_place", nil];
    NSDictionary *sectionB = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:place2, nil], @"additional_place", nil];
    return [NSArray arrayWithObjects:sectionA, sectionB, nil];
}

- (NSArray *)placesWithQueryParams:(NSDictionary *)params
{
    return nil;
}

#pragma mark - RKObjectLoader Delegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    if ([objectLoader wasSentToResourcePath:@"/api/reports"]) {
        ODMReport *report = (ODMReport*)object;
        ODMLog(@"******* SEND report title %@", [report title]);
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    RKLogError(@"!!!!!!!!!!!!!!!!!!!! Loader Error %@", error);
}

@end
