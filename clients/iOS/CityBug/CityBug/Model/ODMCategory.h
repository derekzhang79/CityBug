//
//  ODMCategory.h
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

@interface ODMCategory : NSObject {
    NSString *_title;
    NSString *_thumbnailImage;
}

@property (nonatomic, strong) NSString *title,  *thumbnailImage;

+ (ODMCategory *)categoryWithTitle:(NSString *)category;

@end