//
//  ODMReport.h
//  CityBug
//
//  Created by InICe on 19/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ODMPlace, ODMUser, ODMCategory;

@interface ODMReport : NSObject {
    NSArray  *_categories;
    NSNumber *_latitude, *_longitude;
    NSString *_title, *_note, *_uid;
    UIImage  *_thumbnailImage, *_fullImage;
    ODMPlace *_place;
    ODMUser  *_user;
}

@property (nonatomic, strong) NSString *title, *note, *uid;
@property (nonatomic, strong) NSNumber *latitude, *longitude;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) UIImage *thumbnailImage, *fullImage;
@property (nonatomic, strong) ODMPlace *place;
@property (nonatomic, strong) ODMUser *user;

- (BOOL)validateValue:(__autoreleasing id *)value forKey:(NSString *)key error:(NSError *__autoreleasing *)error;

+ (ODMReport *)newReportWithTitle:(NSString *)title note:(NSString *)note;
@end
