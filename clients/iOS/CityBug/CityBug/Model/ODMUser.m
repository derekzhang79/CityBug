//
//  ODMUser.m
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMUser.h"

@implementation ODMUser

- (id)initWithUser:(NSString *)username email:(NSString *)email password:(NSString *)password
{
    if (self = [super init]) {
        _username = username;
        _email = email;
        _password = password;
    }
    return self;
}

+ (ODMUser *)newUser:(NSString *)username email:(NSString *)email password:(NSString *)password
{
    return [[self alloc] initWithUser:username email:email password:password];
}
@end
