//
//  ODMEntry.m
//  OpendreamBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMEntry.h"
#import "ODMCategory.h"

#define NAME_INVALID_TITLE @"Name does not valid."
#define NAME_INVALID_STRING @"Please use only letters (a-z, A-Z, ก-ฮ), numbers, periods or whitespace"
#define NAME_LENGTH_INVALID @"Name should be less than 30 characters"

#define VALIDATION_USERNAME_REGEXR @"^[a-zA-Z0-9ก-ฮเ-ไ]{1}[a-zA-Z0-9ก-๙]{2}[a-zA-Z0-9ก-๙ _]*"

@implementation ODMEntry

@dynamic title;
@dynamic thumbnailImage;
@dynamic fullImage;
@dynamic latitude;
@dynamic longitude;
@dynamic note;
@dynamic category;

/*
 * Validate title field
 */
- (BOOL)validateTitleField:(NSString *)username
{
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VALIDATION_USERNAME_REGEXR];
    NSString *string = username;
    return [myTest evaluateWithObject:string];
}

- (BOOL)validateValue:(__autoreleasing id *)value forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    if ([key isEqualToString:@"title"]) {
        if (self.title.length > MAXIMUM_CONTACT_NAME_LENGTH) {
            *error = [NSError errorWithDomain:NAME_LENGTH_INVALID code:1002 userInfo:[NSDictionary dictionaryWithObject:self forKey:@"ODMEntry"]];
            return NO;
        } else if ([self validateTitleField:self.title] == NO) {
            *error = [NSError errorWithDomain:NAME_INVALID_STRING code:1003 userInfo:[NSDictionary dictionaryWithObject:self forKey:@"ODMEntry"]];
            return NO;
        }
    }
    return YES;
}

@end
