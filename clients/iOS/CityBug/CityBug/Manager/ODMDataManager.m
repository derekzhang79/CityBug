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

NSString *ODMDataManagerNotificationCommentLoadingFinish;
NSString *ODMDataManagerNotificationCommentLoadingFail;

NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
NSString *ODMDataManagerNotificationCategoriesLoadingFail;

NSString *ODMDataManagerNotificationPlacesLoadingFinish;
NSString *ODMDataManagerNotificationPlacesSearchingFinish;
NSString *ODMDataManagerNotificationPlacesLoadingFail;

NSString *ODMDataManagerNotificationAuthenDidFinish;

@interface ODMDataManager()

/*
 * Read write access only DataManager
 */
@property (nonatomic, readwrite, strong) NSArray *categories, *reports, *places;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;

@end

@implementation ODMDataManager

#pragma mark - Initialize

- (id)init
{
    if (self = [super init]) {
        
        //
        // Initialize Notification Identifier String
        //
        ODMDataManagerNotificationReportsLoadingFinish = @"ODMDataManagerNotificationReportsLoadingFinish";
        ODMDataManagerNotificationReportsLoadingFail = @"ODMDataManagerNotificationReportsLoadingFail";
        
        
        ODMDataManagerNotificationCommentLoadingFinish = @"ODMDataManagerNotificationCommentLoadingFinish";
        ODMDataManagerNotificationCommentLoadingFail = @"ODMDataManagerNotificationCommentLoadingFail";

        ODMDataManagerNotificationCategoriesLoadingFinish = @"ODMDataManagerNotificationCategoriesLoadingFinish";
        ODMDataManagerNotificationCategoriesLoadingFail = @"ODMDataManagerNotificationCategoriesLoadingFail";
        
        ODMDataManagerNotificationPlacesLoadingFinish = @"ODMDataManagerNotificationPlacesLoadingFinish";
        ODMDataManagerNotificationPlacesLoadingFail = @"ODMDataManagerNotificationPlacesLoadingFail";
        ODMDataManagerNotificationPlacesSearchingFinish = @"ODMDataManagerNotificationPlacesSearchingFinish";
        
        ODMDataManagerNotificationAuthenDidFinish = @"ODMDataManagerNotificationAuthenDidFinish";
        
        //
        // RestKit setup
        //
        serviceObjectManager = [RKObjectManager managerWithBaseURLString:BASE_URL];
        serviceObjectManager.client.username = [[self currentUser] username];
        serviceObjectManager.client.password = [[self currentUser] password];
        serviceObjectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
        serviceObjectManager.client.defaultHTTPEncoding = NSUTF8StringEncoding;
        serviceObjectManager.client.cachePolicy = RKRequestCachePolicyNone;
        
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
        
        RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[ODMCategory class]];
        [categoryMapping mapKeyPath:@"title" toAttribute:@"title"];
        
        RKObjectMapping *placeMapping = [RKObjectMapping mappingForClass:[ODMPlace class]];
        [placeMapping mapKeyPath:@"title" toAttribute:@"title"];
        [placeMapping mapKeyPath:@"lat" toAttribute:@"latitude"];
        [placeMapping mapKeyPath:@"lng" toAttribute:@"longitude"];
        [placeMapping mapKeyPath:@"id_foursquare" toAttribute:@"uid"];
        [placeMapping mapKeyPath:@"type" toAttribute:@"type"];

        RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[ODMUser class]];
        [userMapping mapKeyPath:@"username" toAttribute:@"username"];
        [userMapping mapKeyPath:@"password" toAttribute:@"password"];
        [userMapping mapKeyPath:@"email" toAttribute:@"email"];
        [userMapping mapKeyPath:@"_id" toAttribute:@"uid"];
        
        RKObjectMapping *commentMapping = [RKObjectMapping mappingForClass:[ODMComment class]];
        [commentMapping mapKeyPath:@"text" toAttribute:@"text"];
        [commentMapping mapKeyPath:@"_id" toAttribute:@"reportID"];
        [commentMapping mapKeyPath:@"last_modified" toAttribute:@"lastModified"];
        
        
        // Mapping Relation
        
        // [reportMapping mapKeyPath:@"categories" toRelationship:@"categories" withMapping:categoryMapping];
        [reportMapping mapRelationship:@"categories" withMapping:categoryMapping];
        [reportMapping mapRelationship:@"place" withMapping:placeMapping];
        [reportMapping mapRelationship:@"user" withMapping:userMapping];
        [reportMapping mapRelationship:@"comment" withMapping:commentMapping];
        [commentMapping mapRelationship:@"user" withMapping:userMapping];
        
        // Configuration using helper methods
        [reportMapping hasMany:@"comments" withMapping:commentMapping];
        
        [serviceObjectManager.mappingProvider setMapping:reportMapping forKeyPath:@"reports"];
        [serviceObjectManager.mappingProvider setMapping:categoryMapping forKeyPath:@"categories"];
        [serviceObjectManager.mappingProvider setMapping:placeMapping forKeyPath:@"places"];
        [serviceObjectManager.mappingProvider setMapping:userMapping forKeyPath:@"user"];
        [serviceObjectManager.mappingProvider setMapping:commentMapping forKeyPath:@"comments"];
        [serviceObjectManager.mappingProvider addObjectMapping:reportMapping];
        
        // Serialization
        [serviceObjectManager.mappingProvider setSerializationMapping:[reportMapping inverseMapping] forClass:[ODMReport class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:categoryMapping forClass:[ODMCategory class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:placeMapping forClass:[ODMPlace class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:[userMapping inverseMapping] forClass:[ODMUser class]];
        [serviceObjectManager.mappingProvider setSerializationMapping:commentMapping forClass:[ODMComment class]];
        
        // Routing
        [serviceObjectManager.router routeClass:[ODMReport class] toResourcePath:@"/api/reports" forMethod:RKRequestMethodPOST];
        [serviceObjectManager.router routeClass:[ODMCategory class] toResourcePath:@"/api/categories" forMethod:RKRequestMethodGET];
        [serviceObjectManager.router routeClass:[ODMComment class] toResourcePath:@"/api/report/:reportID/comment" forMethod:RKRequestMethodPOST];
        [serviceObjectManager.router routeClass:[ODMUser class] toResourcePath:@"/api/user/sign_up" forMethod:RKRequestMethodPOST];

        [serviceObjectManager.mappingProvider setObjectMapping:reportMapping forResourcePathPattern:@"/api/report/:reportID/comment"];
        
        
        NSError *error = nil;
        [self signInCityBugUserWithError:&error];
        //        self.isAuthenticated = NO;
        
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
    NSString *currentUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *currentPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *currentEmail = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    
    if (currentUsername ==  nil) {
        currentUsername = @"";
    }
    if (currentPassword ==  nil) {
        currentPassword = @"";
    }
    if (currentEmail ==  nil) {
        currentEmail = @"";
    }
//    return [ODMUser newUser:@"admin" email:@"admin@citybug.com" password:@"qwer4321"];
    return [ODMUser newUser:currentUsername email:currentEmail password:currentPassword];
}

- (void)signInCityBugUserWithError:(NSError **)error
{
    serviceObjectManager.client.username = [[self currentUser] username];
    serviceObjectManager.client.password = [[self currentUser] password];
    
    RKParams *reportParams = [RKParams params];
    
    ODMUser *user = [[ODMUser alloc] init];
    
    [[RKObjectManager sharedManager] postObject:user usingBlock:^(RKObjectLoader *loader){
        // user httpbasic no need to set user
        // but set for restkit to mapping key and value
        [reportParams setValue:@"" forParam:@"username"];
        loader.delegate = self;
        [loader setMethod:RKRequestMethodPOST];
        loader.resourcePath = @"/api/user/sign_in";
        loader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForKeyPath:@"/api/user/sign_in"];
        loader.defaultHTTPEncoding = NSUTF8StringEncoding;
        loader.params = reportParams;
    }];

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
    
    if (!report.user) {
        *error = [NSError errorWithDomain:@"User does not exist" code:5001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:@"description", @"Must sign-in before create a new report", nil]];
        return;
    }
    
    [[RKObjectManager sharedManager] postObject:report usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;
        
        [reportParams setValue:[report title] forParam:@"title"];
        [reportParams setValue:[report note] forParam:@"note"];
        [reportParams setValue:[report latitude] forParam:@"lat"];
        [reportParams setValue:[report longitude] forParam:@"lng"];
        [reportParams setValue:[report.user username] forParam:@"username"];
        
        [reportParams setValue:[report.place uid] forParam:@"place_id"];
        [reportParams setValue:[report.place title] forParam:@"place_title"];
        [reportParams setValue:[report.place latitude] forParam:@"place_lat"];
        [reportParams setValue:[report.place longitude] forParam:@"place_lng"];
        
        NSArray *catItems = [report.categories valueForKeyPath:@"title"];
        [reportParams setValue:catItems forParam:@"categories"];
        
        NSData *fullImageData = UIImageJPEGRepresentation(report.fullImageData, 1);
        NSData *thumbnailImageData = UIImageJPEGRepresentation(report.thumbnailImageData, 0);
        
        [reportParams setData:fullImageData MIMEType:@"image/jpeg" forParam:@"full_image"];
        [reportParams setData:thumbnailImageData MIMEType:@"image/jpeg" forParam:@"thumbnail_image"];
        
        loader.defaultHTTPEncoding = NSUTF8StringEncoding;
        
        loader.onDidLoadObject = ^(id object){
            // force to reload all data
            [[ODMDataManager sharedInstance] reports];
        };
        loader.params = reportParams;
    }];
}

/*
 * ADDING A COMMENT
 * HTTP POST
 */

- (void)postComment:(ODMComment *)comment
{
    [self postComment:comment withError:NULL];
}

- (void)postComment:(ODMComment *)comment withError:(NSError **)error
{
    RKParams *reportParams = [RKParams params];
    
    ODMUser *currentUser = [self currentUser];
    comment.user = currentUser;
    
    *error = nil;
    NSString *commentText = comment.text;
    BOOL isValid = [comment validateValue:&commentText forKey:@"text" error:error];
    if (!isValid) {
        @throw [NSException exceptionWithName:[*error domain] reason:[[*error userInfo] objectForKey:@"description"] userInfo:nil];
    }
    
    [[RKObjectManager sharedManager] postObject:comment usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;
        
        [reportParams setValue:[comment text] forParam:@"text"];
        [reportParams setValue:[comment.user username] forParam:@"username"];
        
        loader.onDidLoadObject = ^(id object) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationCommentLoadingFinish object:object];
        };
        
        loader.params = reportParams;
    }];
}

- (void)signUpNewUser:(ODMUser *)user
{
    [self signUpNewUser:user withError:NULL];
}

- (void)signUpNewUser:(ODMUser *)user withError:(NSError **)error
{
//    RKParams *newUserParams = [RKParams params];
    
    [[RKObjectManager sharedManager] postObject:user usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;

        loader.onDidLoadObject = ^(id object){
            NSLog(@"YEAH!!");
        };

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
    if ([self currentUser] && DEBUG_HAS_SIGNED_IN) {
        
        // DEBUG MODE (Helping Mode)
        // We add username and password as query parameters,
        // so that server-side can easily parse and debug as well.
        // However finally, we must use Basic Authentication method
        // which contains HTTPHeader(Authentication) for autherize to
        // citybug back-end instead.
        
        NSString *currentUsername = [[self currentUser] username];
        NSString *currentPassword = [[self currentUser] password];
        
        [queryParams setObject:currentUsername forKey:@"username"];
        [queryParams setObject:currentPassword forKey:@"password"];

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

- (NSMutableDictionary *)buildingQueryParametersWithLocation:(CLLocationCoordinate2D)coordinate withParams:(NSMutableDictionary *)params
{
    [params setObject:@(coordinate.latitude) forKey:@"lat"];
    [params setObject:@(coordinate.longitude) forKey:@"lng"];
    return params;
}

- (void)updateQueryParameterFromLocation:(CLLocationCoordinate2D)loc
{
    [self buildingQueryParametersWithLocation:loc withParams:queryParams];
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
            
            NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO];
            
            _reports = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort1, nil]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationReportsLoadingFinish object:_reports];
        };
    }];
    
    return _reports;
}


- (NSArray *)comment
{
    return [self reportsWithParameters:[self buildingQueryParameters] error:NULL];
}

#pragma mark - CATEGORY
/**
 * Category List
 */
- (NSArray *)categories
{
    [serviceObjectManager loadObjectsAtResourcePath:@"/api/categories" usingBlock:^(RKObjectLoader *loader){
        //loader.objectMapping = [serviceObjectManager.mappingProvider serializationMappingForClass:[ODMCategory class]];
        loader.onDidLoadObjects = ^(NSArray *objects){
            _categories = [NSArray arrayWithArray:objects];
            
            // Post notification with category array
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationCategoriesLoadingFinish object:_categories];
        };
    }];
    
    return _categories;
}

#pragma mark - PLACE
/**
 * Place list
 */
- (NSArray *)places
{
    NSMutableDictionary *paramDict = [NSMutableDictionary new];
    
    paramDict = [self buildingQueryParametersWithLocation:self.locationManager.location.coordinate withParams:paramDict];
    
    NSString *resourcePath = [@"/api/place/search" stringByAppendingQueryParameters:paramDict];
    
    ODMLog(@"query parameters %@", resourcePath);
    
    [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
        loader.onDidLoadObjects = ^(NSArray *objects){
            ODMLog(@"result places %i", [objects count]);
            
            _places = [objects sectionsGroupedByKeyPath:@"type"];
            
            // Post notification with category array
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlacesLoadingFinish object:_places];
        };
    }];
    
    return _places;
}

- (NSArray *)placesWithQueryParams:(NSDictionary *)params
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:params];
    
    paramDict = [self buildingQueryParametersWithLocation:self.locationManager.location.coordinate withParams:paramDict];
    
    NSString *resourcePath = [@"/api/place/search" stringByAppendingQueryParameters:paramDict];
    
    ODMLog(@"query parameters %@", resourcePath);
    
    [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
        loader.onDidLoadObjects = ^(NSArray *objects){
            _filterdPlaces = [objects sectionsGroupedByKeyPath:@"type"];
            
            ODMLog(@"result places %i", [objects count]);
            
            // Post notification with category array
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlacesSearchingFinish object:_filterdPlaces];
        };
    }];
    
    return _filterdPlaces;
}

#pragma mark - RKObjectLoader Delegate

- (void)request:(RKRequest *)request didReceiveResponse:(RKResponse *)response
{
    switch ([response statusCode]) {
        case 200:{
            if ([[[response allHeaderFields] objectForKey:@"Text"] isEqualToString:HEADER_TEXT_AUTHENTICATED]) {
                // authen ok
                self.isAuthenticated = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationAuthenDidFinish object:nil];
            } else if ([[[response allHeaderFields] objectForKey:@"Text"] isEqualToString:@"posted"]) {
                // post ok
            } else if ([[[response allHeaderFields] objectForKey:@"Text"] isEqualToString:@"commented"]) {
                // comment ok
            }
        }
            break;
        case 400:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bad request!" message:@"please contact develop team" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 401:{
            // unauthen
            self.isAuthenticated = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationAuthenDidFinish object:nil];
        }
            break;
        case 404:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh!" message:@"bad access" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 500:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server failed" message:@"Please try again in few minus" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
            
        default:
            break;
    }
}
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
