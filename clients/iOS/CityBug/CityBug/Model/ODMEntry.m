//
//  ODMEntry.m
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMEntry.h"
#import "ODMCategory.h"

@implementation ODMEntry

@dynamic title;
@dynamic thumbnailImage;
@dynamic fullImage;
@dynamic latitude;
@dynamic longitude;
@dynamic note;
@dynamic lastModified;
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
    /*
     * Validate Note field
     */
    } else if ([key isEqualToString:@"note"]) {
        if (self.note.length > MAXIMUM_NOTE_LENGTH) {
            *error = [NSError errorWithDomain:LONG_LENGTH_STRING_ERROR_DOMAIN code:1004 userInfo:[NSDictionary dictionaryWithObject:self forKey:NSStringFromClass([self class])]];
            return NO;
        }
    }
    return YES;
}


@end
