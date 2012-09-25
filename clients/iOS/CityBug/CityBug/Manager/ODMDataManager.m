//
//  ODMDataManager.m
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManager.h"
#import "ODMReport.h"

static ODMDataManager *sharedDataManager = nil;

NSString *ODMDataManagerNotificationReportsLoadingFinish;
NSString *ODMDataManagerNotificationReportsLoadingFail;

NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
NSString *ODMDataManagerNotificationCategoriesLoadingFail;

NSString *ODMDataManagerNotificationPlacesLoadingFinish;
NSString *ODMDataManagerNotificationPlacesLoadingFail;

@interface ODMDataManager(Accessor)
/*
 * Read write access only DataManager
 */
@property (nonatomic, readwrite, strong) NSArray *categories, *reports, *places;

@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@end

@implementation ODMDataManager {
    NSMutableDictionary *queryParams;
}

#pragma mark - Initialize

- (id)init
{
    if (self = [super init]) {
        
        //
        // Initialize Notification Identifier String
        //
        ODMDataManagerNotificationReportsLoadingFinish = @"ODMDataManagerNotificationReportsLoadingFinish";
        ODMDataManagerNotificationReportsLoadingFail = @"ODMDataManagerNotificationReportsLoadingFail";
        
        ODMDataManagerNotificationCategoriesLoadingFinish = @"ODMDataManagerNotificationCategoriesLoadingFinish";
        ODMDataManagerNotificationCategoriesLoadingFail = @"ODMDataManagerNotificationCategoriesLoadingFail";
        
        ODMDataManagerNotificationPlacesLoadingFinish = @"ODMDataManagerNotificationPlacesLoadingFinish";
        ODMDataManagerNotificationPlacesLoadingFail = @"ODMDataManagerNotificationPlacesLoadingFail";
        
        //
        // RestKit setup
        //
        serviceObjectManager = [RKObjectManager managerWithBaseURLString:BASE_URL];
        serviceObjectManager.client.username = [[self currentUser] username];
        serviceObjectManager.client.password = [[self currentUser] password];
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
        [reportMapping mapKeyPath:@"imin_count" toAttribute:@"iminCount"];
        [reportMapping mapKeyPath:@"last_modified" toAttribute:@"lastModified"];
        [reportMapping mapKeyPath:@"_id" toAttribute:@"uid"];
        [serviceObjectManager.mappingProvider addObjectMapping:reportMapping];
        
        RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[ODMCategory class]];
        [categoryMapping mapKeyPath:@"title" toAttribute:@"title"];
        
        RKObjectMapping *placeMapping = [RKObjectMapping mappingForClass:[ODMPlace class]];
        [placeMapping mapKeyPath:@"title" toAttribute:@"title"];
        [placeMapping mapKeyPath:@"lat" toAttribute:@"latitude"];
        [placeMapping mapKeyPath:@"lng" toAttribute:@"longitude"];
        [placeMapping mapKeyPath:@"id_foursquare" toAttribute:@"uid"];
        [placeMapping mapKeyPath:@"type" toAttribute:@"type"];

        RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[ODMUser class]];
        [userMapping mapAttributes:@"username", @"email", @"password", nil];
        [userMapping mapKeyPath:@"_id" toAttribute:@"uid"];
        
        // Mapping Relation
        // [reportMapping mapKeyPath:@"categories" toRelationship:@"categories" withMapping:categoryMapping];
        [reportMapping mapRelationship:@"categories" withMapping:categoryMapping];
        [reportMapping mapRelationship:@"place" withMapping:placeMapping];
        [reportMapping mapRelationship:@"user" withMapping:userMapping];
        
        [serviceObjectManager.mappingProvider setMapping:reportMapping forKeyPath:@"reports"];
        [serviceObjectManager.mappingProvider setMapping:categoryMapping forKeyPath:@"categories"];
        [serviceObjectManager.mappingProvider setMapping:placeMapping forKeyPath:@"places"];
        [serviceObjectManager.mappingProvider setMapping:userMapping forKeyPath:@"user"];
        
        // Serialization
        [serviceObjectManager.mappingProvider setSerializationMapping:[reportMapping inverseMapping] forClass:[ODMReport class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:categoryMapping forClass:[ODMCategory class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:placeMapping forClass:[ODMPlace class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:userMapping forClass:[ODMUser class]];
        
        // Routing
        [serviceObjectManager.router routeClass:[ODMReport class] toResourcePath:@"/api/reports" forMethod:RKRequestMethodPOST];
        [serviceObjectManager.router routeClass:[ODMCategory class] toResourcePath:@"/api/categories" forMethod:RKRequestMethodGET];
        [serviceObjectManager.router routeClass:[ODMComment class] toResourcePath:@"/api/report/:reportID/comment" forMethod:RKRequestMethodPOST];
        
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

- (BOOL)startGatheringLocation
{
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:@"CityBug" message:NSLocalizedString(REQUIRE_LOCATION_SERVICES_TEXT, REQUIRE_LOCATION_SERVICES_TEXT) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [locationAlert show];
        return NO;
    }
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    
    [_locationManager startUpdatingLocation];
    
    return YES;
}

- (BOOL)stopGatheringLocation
{
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
        return YES;
    }
    
    return NO;
}

#pragma mark - USER

- (ODMUser *)currentUser
{
    return [ODMUser newUser:@"admin" email:@"user@citybug.com" password:@"qwer4321"];
}

#pragma mark - REPORT

/*
 * CREATE REPORT
 * HTTP POST
 */
- (void)postNewReport:(ODMReport *)report
{
    [self postNewReport:report error:NULL];
}

- (void)postNewReport:(ODMReport *)report error:(NSError **)error
{
    RKParams *reportParams = [RKParams params];

    report.user = [self currentUser];
    
    ODMUser *admin = [ODMUser newUser:@"admin" email:@"admin@opendream.co.th" password:@"qwer4321"];
    if (!admin) {
        *error = [NSError errorWithDomain:@"User does not exist" code:5001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:@"description", @"Must sign-in before create a new report", nil]];
        return;
    }
    
    [[RKObjectManager sharedManager] postObject:report usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;
        
        [reportParams setValue:[report title] forParam:@"title"];
        [reportParams setValue:[report note] forParam:@"note"];
        [reportParams setValue:[report latitude]   forParam:@"lat"];
        [reportParams setValue:[report longitude] forParam:@"lng"];
        [reportParams setValue:[report.user username] forParam:@"username"];
        
        [reportParams setValue:[report.place uid] forParam:@"place_id"];
        [reportParams setValue:[report.place title] forParam:@"place_title"];
        [reportParams setValue:[report.place latitude] forParam:@"place_lat"];
        [reportParams setValue:[report.place longitude] forParam:@"place_lng"];
        
        NSArray *catItems = [report.categories valueForKeyPath:@"title"];
        [reportParams setValue:catItems forParam:@"categories"];
        
        NSData *fullImageData = UIImageJPEGRepresentation(report.fullImageData, 1);
        NSData *thumbnailImageData = UIImageJPEGRepresentation(report.thumbnailImageData, 1);
        
        [reportParams setData:fullImageData MIMEType:@"image/jpeg" forParam:@"full_image"];
        [reportParams setData:thumbnailImageData MIMEType:@"image/jpeg" forParam:@"thumbnail_image"];
        
        loader.defaultHTTPEncoding = NSUTF8StringEncoding;
        loader.params = reportParams;
    }];
}



- (void)postComment:(ODMComment *)comment
{
    RKParams *reportParams = [RKParams params];
    
    ODMUser *user = [ODMUser newUser:@"admin" email:@"admin@opendream.co.th" password:@"1234qwer"];
    comment.user = user;
    [[RKObjectManager sharedManager] postObject:comment usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;
        
        [reportParams setValue:[comment text] forParam:@"text"];
        [reportParams setValue:[comment.user username] forParam:@"username"];

        loader.params = reportParams;
    }];
}


/**
 * Update Query parameters
 * For getting contents in recent activity view
 */
- (NSMutableDictionary *)buildingQueryParameters
{
    if (!queryParams) {
        queryParams = [NSMutableDictionary new];
        [queryParams setObject:@30 forKey:@"limit"];
    }
    
    // Check whether current user has signed in
    if ([self currentUser]) {
        
        // DEBUG MODE (Helping Mode)
        // We add username and password as query parameters,
        // so that server-side can easily parse and debug as well.
        // However finally, we must use Basic Authentication method
        // which contains HTTPHeader(Authentication) for autherize to
        // citybug back-end instead.
        [queryParams setObject:@"admin" forKey:@"username"];
        [queryParams setObject:@"qwer4321" forKey:@"password"];
    }
    
    if ([self startGatheringLocation]) {
        // Location services are enable
        [self updateQueryParameterFromLocation:self.locationManager.location.coordinate];
        
        if (self.locationManager.location.horizontalAccuracy < MINIMUN_ACCURACY_DISTANCE && self.locationManager.location.verticalAccuracy < MINIMUN_ACCURACY_DISTANCE && MIN(self.locationManager.location.horizontalAccuracy, 0) == 0 && MIN(self.locationManager.location.verticalAccuracy, 0) == 0) {
            [self stopGatheringLocation];
        }
    }
    
    return queryParams;
}

- (void)updateQueryParameterFromLocation:(CLLocationCoordinate2D)loc
{
    [queryParams setObject:@(loc.latitude) forKey:@"lat"];
    [queryParams setObject:@(loc.longitude) forKey:@"lng"];
}

- (NSArray *)reports
{
    return [self reportsWithParameters:[self buildingQueryParameters] error:NULL];
}

- (NSArray *)reportsWithParameters:(NSDictionary *)params error:(NSError **)error
{

    NSString *resourcePath = [@"/api/reports" stringByAppendingQueryParameters:params];
    
    [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
        loader.onDidLoadObjects = ^(NSArray *objects){
            reports_ = [NSArray arrayWithArray:objects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationReportsLoadingFinish object:reports_];
        };
    }];
    
    return reports_;
}

#pragma mark - CATEGORY
/**
 * Category List
 */
- (NSArray *)categories
{
    if (!categories_) {
        
        [serviceObjectManager loadObjectsAtResourcePath:@"/api/categories" usingBlock:^(RKObjectLoader *loader){
            //loader.objectMapping = [serviceObjectManager.mappingProvider serializationMappingForClass:[ODMCategory class]];
            loader.onDidLoadObjects = ^(NSArray *objects){
                categories_ = [NSArray arrayWithArray:objects];
                
                // Post notification with category array
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationCategoriesLoadingFinish object:categories_];
            };
        }];
    }
    
    return categories_;
}

#pragma mark - PLACE
/**
 * Place list
 */
- (NSArray *)places
{
    if (!places_) {
        
        NSDictionary *qp = [NSDictionary dictionaryWithKeysAndObjects:@"lat", @"10.33023",
                                     @"lng", @"133.324523", nil];
        NSString *resourcePath = [@"/api/place/search" stringByAppendingQueryParameters:qp];
        
        [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
            loader.onDidLoadObjects = ^(NSArray *objects){
                places_ = [objects sectionsGroupedByKeyPath:@"type"];
                
                // Post notification with category array
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlacesLoadingFinish object:places_];
            };
        }];
    }
    
    return places_;
}

- (void)placesWithQueryParams:(NSDictionary *)params
{
    NSString *resourcePath = [@"/api/place/search" stringByAppendingQueryParameters:params];
    [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
        loader.onDidLoadObjects = ^(NSArray *objects){
            places_ = [objects sectionsGroupedByKeyPath:@"type"];
            
            // Post notification with category array
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlacesLoadingFinish object:places_];
        };
    }];
}

#pragma mark - RKObjectLoader Delegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    RKLogError(@"******* SUCCESSFULLY SEND %@", object);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    RKLogError(@"!!!!!!!!!!!!!!!!!!!! Loader Error %@", error);
}


#pragma mark - CLLocationManager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    CLLocation *location = [locations lastObject];
//    [userDefault setObject:location forKey:USER_CURRENT_LOCATION];
//    [userDefault synchronize];
}

@end
