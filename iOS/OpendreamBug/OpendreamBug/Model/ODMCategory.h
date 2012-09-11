//
//  ODMCategory.h
//  OpendreamBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ODMEntry;

@interface ODMCategory : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSSet *entries;
@end

@interface ODMCategory (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(ODMEntry *)value;
- (void)removeEntriesObject:(ODMEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
