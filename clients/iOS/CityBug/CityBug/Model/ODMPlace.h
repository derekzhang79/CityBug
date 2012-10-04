//
//  ODMPlace.h
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

@interface ODMPlace : NSObject {
    NSString *_title, *_uid, *_type;
    NSNumber *_latitude, *_longitude;
    BOOL _isSubscribed;
}

@property (nonatomic, strong) NSString *title, *uid, *type;
@property (nonatomic, strong) NSNumber *latitude, *longitude;
@property (nonatomic, assign) BOOL isSubscribed;

+ (ODMPlace *)placeWithTitle:(NSString *)title latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude uid:(NSString *)uid type:(NSString *)type isSubscribed:(BOOL)isSubscribed;

@end
