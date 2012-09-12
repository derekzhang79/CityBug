//
//  ODMDataManager.h
//  OpendreamBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

@interface ODMDataManager : NSObject {
    NSManagedObjectContext *defaultContext;
}

+ (id)sharedInstance;

/*
 * List all entries
 */
- (NSArray *)get:(NSString *)api;

/*
 * Insert/Update entries
 */
- (BOOL)insertEntriesToPersistentStore:(NSArray *)entries withManagedObjectContext:(NSManagedObjectContext *)context;

@end
