//
//  ODMUser.h
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODMUser : NSObject {
    NSString *_email, *_username, *_uid, *_password;
}

@property (nonatomic, strong) NSString *username, *email, *uid, *password;

+ (ODMUser *)newUser:(NSString *)username email:(NSString *)email password:(NSString *)password;

@end
