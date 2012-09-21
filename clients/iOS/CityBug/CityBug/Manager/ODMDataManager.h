//
//  ODMDataManager.h
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMReport.h"
#import "ODMCategory.h"
#import "ODMPlace.h"

// Category
extern NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
extern NSString *ODMDataManagerNotificationCategoriesLoadingFail;
// Place
extern NSString *ODMDataManagerNotificationPlacesLoadingFinish;
extern NSString *ODMDataManagerNotificationPlacesLoadingFail;

@class ODMReport;

@interface ODMDataManager : NSObject <RKObjectLoaderDelegate> {
    RKObjectManager *serviceObjectManager;
    
    NSArray *reports_, *categories_, *places_;
}

@property (nonatomic, readonly ,strong) NSArray *reports, *categories, *places;

/*
 * Singleton pattern
 */
+ (id)sharedInstance;

/*
 * Get all entries
 */
- (NSArray *)getEntryList;

/*
 * Post New Report
 */
- (void)postNewReport:(ODMReport *)report;


/*
 * Places
 */
- (void)placesWithQueryParams:(NSDictionary *)params;

@end
