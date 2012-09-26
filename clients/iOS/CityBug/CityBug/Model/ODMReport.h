//
//  ODMReport.h
//  CityBug
//
//  Created by InICe on 19/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMPlace.h"
#import "ODMUser.h"
#import "ODMCategory.h"
#import "ODMComment.h"

@interface ODMReport : NSObject {
    NSArray  *_categories, *_comments;
    NSNumber *_latitude, *_longitude, *_iminCount;
    NSString *_title, *_note, *_uid, *_thumbnailImage, *_fullImage;;
    UIImage  *_thumbnailImageData, *_fullImageData;
    ODMPlace *_place;
    ODMUser  *_user;
    
    NSDate *_lastModified;
}

@property (nonatomic, strong) NSString *title, *note, *uid, *thumbnailImage, *fullImage;
@property (nonatomic, strong) NSNumber *latitude, *longitude, *iminCount;
@property (nonatomic, strong) NSArray *categories, *comments;
@property (nonatomic, strong) UIImage *thumbnailImageData, *fullImageData;
@property (nonatomic, strong) ODMPlace *place;
@property (nonatomic, strong) ODMUser *user;
@property (nonatomic, strong) ODMComment *comment;
@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) NSDate *lastModified;

- (BOOL)validateValue:(__autoreleasing id *)value forKey:(NSString *)key error:(NSError *__autoreleasing *)error;

+ (ODMReport *)newReportWithTitle:(NSString *)title note:(NSString *)note;

/*
 * I'm in string
 * if there has no people takes part in the report, we will use "Nobody is in yet"
 * otherwise, use pattern "<imin>'re in"
 */
- (NSString *)iminString;

- (void)addComment:(ODMComment *) comment;
@end
