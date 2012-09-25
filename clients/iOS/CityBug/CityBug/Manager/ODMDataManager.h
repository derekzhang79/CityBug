//
//  ODMDataManager.h
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

#import "ODMComment.h"

@class ODMReport, ODMUser;


@interface ODMDataManager : NSObject <RKObjectLoaderDelegate, CLLocationManagerDelegate> {
    RKObjectManager *serviceObjectManager;
    
    NSArray *reports_, *categories_, *places_;
    
    CLLocationManager *_locationManager;
}

@property (nonatomic, readonly ,strong) CLLocationManager *locationManager;

@property (nonatomic, readonly ,strong) NSArray *reports, *categories, *places;

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

/*
 * Get Reports by user and query parameters
 */
- (NSArray *)reportsWithParameters:(NSDictionary *)params error:(NSError **)error;


/*
 * Places
 */
- (void)placesWithQueryParams:(NSDictionary *)params;

/*
 * CurrentUser
 */
- (ODMUser *)currentUser;
@end
