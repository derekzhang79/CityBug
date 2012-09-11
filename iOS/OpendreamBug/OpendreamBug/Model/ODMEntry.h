//
//  ODMEntry.h
//  OpendreamBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ODMCategory;

@interface ODMEntry : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * thumbnailImage;
@property (nonatomic, retain) NSString * fullImage;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) ODMCategory *category;

@end
