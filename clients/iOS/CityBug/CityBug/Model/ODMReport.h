//
//  ODMReport.h
//  CityBug
//
//  Created by InICe on 19/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODMReport : NSObject {
    NSString *_title, *_note;
    NSArray *_categories, *_places;
    double lat, lng;
    UIImage *_thumbnailImage, *_fullImage;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) UIImage *thumbnailImage, *fullImage;

@end
