//
//  ODMCategory.m
//  OpendreamBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMCategory.h"
#import "ODMEntry.h"

@implementation ODMCategory

@dynamic title;
@dynamic entries;

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
    /*
     * Validate Title field
     */
    if ([key isEqualToString:@"title"]) {
        if (self.title.length > MAXIMUM_ENTRY_LENGTH) {
            *error = [NSError errorWithDomain:NAME_LENGTH_INVALID code:1002 userInfo:[NSDictionary dictionaryWithObject:self forKey:NSStringFromClass([self class])]];
            return NO;
        } else if ([self validateTitleField:self.title] == NO) {
            *error = [NSError errorWithDomain:NAME_INVALID_STRING code:1003 userInfo:[NSDictionary dictionaryWithObject:self forKey:NSStringFromClass([self class])]];
            return NO;
        }
    }
    return YES;
}

@end
