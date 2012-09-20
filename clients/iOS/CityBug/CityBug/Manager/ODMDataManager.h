//
//  ODMDataManager.h
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

extern NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
extern NSString *ODMDataManagerNotificationCategoriesLoadingFail;

@class ODMReport;

@interface ODMDataManager : NSObject <RKObjectLoaderDelegate> {
    RKObjectManager *serviceObjectManager;
    
    NSArray *reports_, *categories_;
}

@property (nonatomic, readonly ,strong) NSArray *reports, *categories;

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

@end
