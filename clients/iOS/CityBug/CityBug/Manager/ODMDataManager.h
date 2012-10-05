//
//  ODMDataManager.h
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

#import "ODMComment.h"

@class ODMReport, ODMUser, ODMPlace;

@interface ODMDataManager : NSObject <RKObjectLoaderDelegate, CLLocationManagerDelegate> {
@private
    RKObjectManager *serviceObjectManager;

    NSArray *_reports, *_categories, *_places, *_filterdPlaces, *_mySubscription, *_myReports, *_placeReports;
    
    NSMutableDictionary *queryParams;
    CLLocationManager *_locationManager;
}

@property (nonatomic, readonly ,strong) CLLocationManager *locationManager;


@property (nonatomic, readonly ,strong) NSArray *reports, *categories, *places, *mySubscription, *myReports, *placeReports;
@property (nonatomic, assign) BOOL isAuthenticated;

/*
 * Singleton pattern
 */
+ (id)sharedInstance;

/*
 * Post New Report
 */
- (void)postNewReport:(ODMReport *)report;
- (void)postNewReport:(ODMReport *)report error:(NSError **)error;

/*
 * Post Comment
 */
- (void)postComment:(ODMComment *)comment;
- (void)postComment:(ODMComment *)comment withError:(NSError **)error;

/*
 * Get Reports by user and query parameters
 */
- (NSArray *)reportsWithParameters:(NSDictionary *)params error:(NSError **)error;

/*
 * Get Reports by username
 */
- (NSArray *)reportsWithUsername:(NSString *)username error:(NSError **)error;

/*
 * Get Reports by place
 */
- (NSArray *)reportsWithPlace:(ODMPlace *)place;

/*
 * Sign Up New User
 */
- (void)signUpNewUser:(ODMUser *)user;
/*
 * Places
 */
- (NSArray *)mySubscriptions;
/*
 * Places
 */
- (NSArray *)placesWithQueryParams:(NSDictionary *)params;

- (void)postNewSubscribeToPlace:(ODMPlace *)place;

/*
 * CurrentUser
 */
- (ODMUser *)currentUser;
- (void)signInCityBugUserWithError:(NSError **)error;
- (void)signOut;

@end
