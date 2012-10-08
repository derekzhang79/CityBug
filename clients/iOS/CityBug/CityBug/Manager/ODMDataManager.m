//
//  ODMDataManager.m
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMPlace.h"

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
NSString *ODMDataManagerNotificationSignUpDidFinish;

NSString *ODMDataManagerNotificationMySubscriptionLoadingFinish;
NSString *ODMDataManagerNotificationMySubscriptionLoadingFail;

NSString *ODMDataManagerNotificationMyReportsLoadingFinish;
NSString *ODMDataManagerNotificationMyReportsLoadingFail;

NSString *ODMDataManagerNotificationPlaceReportsLoadingFinish;
NSString *ODMDataManagerNotificationPlaceReportsLoadingFail;

NSString *ODMDataManagerNotificationPlaceSubscribeDidFinish;
NSString *ODMDataManagerNotificationPlaceSubscribeDidFail;

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
        ODMDataManagerNotificationSignUpDidFinish = @"ODMDataManagerNotificationSignUpDidFinish";
        
        ODMDataManagerNotificationMySubscriptionLoadingFinish = @"ODMDataManagerNotificationMySubscriptionLoadingFinish";
        ODMDataManagerNotificationMySubscriptionLoadingFail = @"ODMDataManagerNotificationMySubscriptionLoadingFail";
        
        ODMDataManagerNotificationMyReportsLoadingFinish = @"ODMDataManagerNotificationMyReportsLoadingFinish";
        ODMDataManagerNotificationMyReportsLoadingFail = @"ODMDataManagerNotificationMyReportsLoadingFail";
        
        ODMDataManagerNotificationPlaceReportsLoadingFinish = @"ODMDataManagerNotificationPlaceReportsLoadingFinish";
        ODMDataManagerNotificationPlaceReportsLoadingFail = @"ODMDataManagerNotificationPlaceReportsLoadingFail";
        
        
        ODMDataManagerNotificationPlaceSubscribeDidFinish = @"ODMDataManagerNotificationPlaceSubscribeDidFinish";
        ODMDataManagerNotificationPlaceSubscribeDidFail = @"ODMDataManagerNotificationPlaceSubscribeDidFail";
        
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
        [reportMapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
        [reportMapping mapKeyPath:@"_id" toAttribute:@"uid"];
        
        RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[ODMCategory class]];
        [categoryMapping mapKeyPath:@"title" toAttribute:@"title"];
        
        RKObjectMapping *placeMapping = [RKObjectMapping mappingForClass:[ODMPlace class]];
        [placeMapping mapKeyPath:@"title" toAttribute:@"title"];
        [placeMapping mapKeyPath:@"lat" toAttribute:@"latitude"];
        [placeMapping mapKeyPath:@"lng" toAttribute:@"longitude"];
        [placeMapping mapKeyPath:@"id_foursquare" toAttribute:@"uid"];
        [placeMapping mapKeyPath:@"type" toAttribute:@"type"];
        [placeMapping mapKeyPath:@"is_subscribed" toAttribute:@"isSubscribed"];
        
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
        //setSerializationMapping = server > mobile obj
        //inverse map = สลับ key path กับ attribute
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
        [serviceObjectManager.router routeClass:[ODMPlace class] toResourcePath:@"/api/subscription/place/" forMethod:RKRequestMethodPOST];
        
        [serviceObjectManager.mappingProvider setObjectMapping:reportMapping forResourcePathPattern:@"/api/report/:reportID/comment"];
        
        // check user when open application
        NSError *error = nil;
        [self signInCityBugUserWithError:&error];
        
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

// monitor the authorization status for the application changed
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == 2) {
        UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:@"CityBug" message:NSLocalizedString(REQUIRE_LOCATION_SERVICES_TEXT, REQUIRE_LOCATION_SERVICES_TEXT) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [locationAlert show];
    }
    if (status == 3) {
        [self startGatheringLocation];
    }
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

/*
 * GET CURRENTUSER, who is sign in now
 */
- (ODMUser *)currentUser
{
    NSString *currentUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *currentPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *currentEmail = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    NSString *currentThumbnail = [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"thumbnailImage"];
    
    if (currentUsername ==  nil) {
        currentUsername = @"";
    }
    if (currentPassword ==  nil) {
        currentPassword = @"";
    }
    if (currentEmail ==  nil) {
        currentEmail = @"";
    }
    if (currentThumbnail ==  nil) {
        currentThumbnail = @"";
    }
//    return [ODMUser newUser:@"admin" email:@"admin@citybug.com" password:@"qwer4321"];
    return [ODMUser newUser:currentUsername email:currentEmail password:currentPassword thumbnailImage:currentThumbnail];
}

- (void)signOut
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"thumbnailImage"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSError *error = nil;
    // use http basic authen
    [[ODMDataManager sharedInstance] signInCityBugUserWithError:&error];}

/*
 * SIGN IN
 * HTTP POST
 */
- (void)signInCityBugUserWithError:(NSError **)error
{
    serviceObjectManager.client.username = [[self currentUser] username];
    serviceObjectManager.client.password = [[self currentUser] password];

    ODMUser *user = [[ODMUser alloc] init];
    
    [[RKObjectManager sharedManager] postObject:user usingBlock:^(RKObjectLoader *loader){
        // user httpbasic no need to set user
        
        loader.delegate = self;
        [loader setMethod:RKRequestMethodPOST];
        loader.resourcePath = @"/api/user/sign_in";
        loader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForKeyPath:@"/api/user/sign_in"];
        loader.onDidLoadObject = ^(id object){
            if (object != NULL) {
                [[NSUserDefaults standardUserDefaults] setValue:[object valueForKey:@"username"] forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] setValue:[object valueForKey:@"password"] forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setValue:[object valueForKey:@"email"] forKey:@"email"];
                [[NSUserDefaults standardUserDefaults] setValue:[object valueForKey:@"thumbnailImage"] forKey:@"thumbnailImage"];
            }
        };
    }];

}


/*
 * SIGN UP NEW USER
 * HTTP POST
 */

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
- (NSArray *)myReports
{
    return [self reportsWithUsername:[[self currentUser] username] error:NULL];
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

- (NSArray *)reportsWithPlace:(ODMPlace *)place
{
    NSString *resourcePath = [@"/api/reports/place" stringByAppendingPathComponent:place.uid];
    
    [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
        loader.onDidLoadObjects = ^(NSArray *objects){
            
            NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO];
            
            _placeReports = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort1, nil]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlaceReportsLoadingFinish object:_placeReports];
        };
    }];
    
    return _placeReports;
}

- (NSArray *)reportsWithUsername:(NSString *)username
{
    return [self reportsWithUsername:username error:NULL];
}

- (NSArray *)reportsWithUsername:(NSString *)username error:(NSError **)error
{
    
    NSString *resourcePath = [@"/api/reports/user" stringByAppendingPathComponent:username];
    
    [serviceObjectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader){
        loader.onDidLoadObjects = ^(NSArray *objects){
            
            NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO];
            
            _myReports = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort1, nil]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationMyReportsLoadingFinish object:_myReports];
        };
    }];
    
    return _myReports;
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

- (void)postNewSubscribeToPlace:(ODMPlace *)place
{
    
    RKParams *placeParams = [RKParams params];
        
    [[RKObjectManager sharedManager] postObject:place usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;

        [placeParams setValue:[place uid] forParam:@"place_id"];
        [placeParams setValue:[place title] forParam:@"place_title"];
        [placeParams setValue:[place latitude] forParam:@"place_lat"];
        [placeParams setValue:[place longitude] forParam:@"place_lng"];
        
        loader.defaultHTTPEncoding = NSUTF8StringEncoding;
        
        loader.onDidLoadObject = ^(id object){
//            if (object != NULL) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlaceSubscribeDidFinish object:object];
//            }
        };
        loader.params = placeParams;
    }];
}

- (NSArray *)mySubscriptions
{
    return [self mySubscriptionWithError:NULL];
}

- (NSArray *)mySubscriptionWithError:(NSError **)error
{

    NSString *resourcPath = [@"/api/subscriptions/user/" stringByAppendingString:[self currentUser].username];
    NSLog(@"username %@", [self currentUser].username);

    [serviceObjectManager loadObjectsAtResourcePath:resourcPath usingBlock:^(RKObjectLoader *loader){
        loader.onDidLoadObjects = ^(NSArray *objects){
          // Post notification with category array
            _mySubscription = objects;
            
            NSLog(@"-------------------------- On Load");
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationMySubscriptionLoadingFinish object:_mySubscription];
        };
    }];
    
    return _mySubscription;
}

#pragma mark - RKObjectLoader Delegate

- (void)request:(RKRequest *)request didReceiveResponse:(RKResponse *)response
{
    NSString *headerText = [[response allHeaderFields] objectForKey:@"Text"];
    switch ([response statusCode]) {
        case 200:{
            if ([headerText isEqualToString:HEADER_TEXT_AUTHENTICATED]) {
                // authen ok
                self.isAuthenticated = YES;
                [[NSUserDefaults standardUserDefaults] setBool:self.isAuthenticated forKey:@"isAuthenticated"];
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationAuthenDidFinish object:nil];
            } else if ([headerText isEqualToString:@"posted"]) {
                // post ok
            } else if ([headerText isEqualToString:@"commented"]) {
                // comment ok
            } else if ([headerText isEqualToString:HEADER_TEXT_SIGNUP_COMPLETE]) {
                // sign up ok
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationSignUpDidFinish object:nil];
            } else if ([headerText isEqualToString:HEADER_TEXT_SUBSCRIBE_COMPLETE]) {
                // subscribe ok
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlaceSubscribeDidFinish object:nil];
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
            [[NSUserDefaults standardUserDefaults] setBool:self.isAuthenticated forKey:@"isAuthenticated"];
            [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationAuthenDidFinish object:nil];
        }
            break;
        case 404:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh!" message:@"bad access" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 500:{
            // Server failed
            
            if ([headerText isEqualToString:HEADER_TEXT_USERNAME_EXISTED]) {
                // sign up failed because username is existed
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationSignUpDidFinish object:HEADER_TEXT_USERNAME_EXISTED];
                
            }else if ([headerText isEqualToString:HEADER_TEXT_EMAIL_EXISTED]) {
                // sign up failed because email is existed
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationSignUpDidFinish object:HEADER_TEXT_EMAIL_EXISTED];
            }else if ([headerText isEqualToString:HEADER_TEXT_CAN_NOT_GET_REPORT_PLACE]) {
                // sign up failed because email is existed
                [[NSNotificationCenter defaultCenter] postNotificationName:ODMDataManagerNotificationPlaceReportsLoadingFail object:HEADER_TEXT_CAN_NOT_GET_REPORT_PLACE];
            }
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
