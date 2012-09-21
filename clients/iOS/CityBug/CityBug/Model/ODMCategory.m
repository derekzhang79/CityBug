//
//  ODMCategory.m
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMCategory.h"

@implementation ODMCategory

- (id)initWithCategoryTitle:(NSString *)category
{
    if (self = [super init]) {
        _title = category;
    }
    return self;
}

+ (ODMCategory *)categoryWithTitle:(NSString *)category
{
    return [[self alloc] initWithCategoryTitle:category];
}

@end
