//
//  ODMDataManager.h
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

@class ODMReport;

@interface ODMDataManager : NSObject <RKObjectLoaderDelegate> {
    NSManagedObjectContext *defaultContext;
}

+ (id)sharedInstance;

/*
 * Insert/Update entries
 */
- (BOOL)insertEntriesToPersistentStore:(NSArray *)entries withManagedObjectContext:(NSManagedObjectContext *)context;

/*
 * Get all entries
 */
- (NSArray *)getEntryList;

- (void)postNewEntry:(UIImage *)aImage title:(NSString *)aTitle note:(NSString *)aNote;

/*
 * Post New Report
 */
- (void)postNewReport:(ODMReport *)report;

@end
