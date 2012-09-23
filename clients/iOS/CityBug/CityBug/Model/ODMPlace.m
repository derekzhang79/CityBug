//
//  ODMPlace.m
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMPlace.h"

@implementation ODMPlace

- (id)initWithPlaceWithTitle:(NSString *)title latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude uid:(NSString *)theUID type:(NSString *)type
{
    if (self = [super init]) {
        _uid = theUID;
        _title = title;
        _latitude = latitude;
        _longitude = longitude;
        _type = type;
    }
    return self;
}

+ (ODMPlace *)placeWithTitle:(NSString *)title latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude uid:(NSString *)uid type:(NSString *)type
{
    return [[self alloc] initWithPlaceWithTitle:title latitude:latitude longitude:longitude uid:uid type:type];
}
            
@end
