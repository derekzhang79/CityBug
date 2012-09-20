//
//  ODMReport.h
//  CityBug
//
//  Created by InICe on 19/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ODMPlace;

@interface ODMReport : NSObject {
    NSArray  *_categories;
    NSNumber *_latitude, *_longitude;
    NSString *_title, *_note;
    UIImage  *_thumbnailImage, *_fullImage;
    ODMPlace *place_;
}

@property (nonatomic, strong) NSString *title, *note;
@property (nonatomic, strong) NSNumber *latitude, *longitude;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) UIImage *thumbnailImage, *fullImage;
@property (nonatomic, strong) ODMPlace *place;
@end
