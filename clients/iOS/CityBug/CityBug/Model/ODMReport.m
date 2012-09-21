//
//  ODMReport.m
//  CityBug
//
//  Created by InICe on 19/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMReport.h"

@implementation ODMReport

- (id)initWithTitle:(NSString *)title note:(NSString *)note
{
    if (self = [super init]) {
        _title = title;
        _note = note;
    }
    return self;
}

+ (ODMReport *)newReportWithTitle:(NSString *)title note:(NSString *)note
{
    return [[self alloc] initWithTitle:title note:note];
}

/*
 * Validate title field
 */
- (BOOL)validateTitleField:(NSString *)title
{
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VALIDATION_TITLE_REGEXR];
    NSString *string = title;
    return [myTest evaluateWithObject:string];
}

- (BOOL)validateLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude
{
    return NO;
}

/**
 * ERROR CODE
 * 1xxx - Validation string error
 * 2xxx - Location services error
 */

- (BOOL)validateValue:(__autoreleasing id *)value forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    /*
     * Validate Title field
     */
    if ([key isEqualToString:@"title"]) {
        if (self.title.length > MAXIMUM_REPORT_LENGTH) {
            *error = [NSError errorWithDomain:TITLE_INVALID_TEXT code:1002 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(TITLE_INVALID_DESCRIPTION_TEXT, TITLE_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        } else if ([self validateTitleField:self.title] == NO) {
            *error = [NSError errorWithDomain:TITLE_LENGTH_INVALID_TEXT code:1003 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(TITLE_LENGTH_INVALID_DESCRIPTION_TEXT, TITLE_LENGTH_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        }
    } else if ([key isEqualToString:@"note"]) {
        if (self.note.length > MAXIMUM_REPORT_LENGTH) {
            *error = [NSError errorWithDomain:LONG_LENGTH_STRING_ERROR_DOMAIN code:1004 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LONG_LENGTH_STRING_ERROR_DESCRIPTION_TEXT, LONG_LENGTH_STRING_ERROR_DESCRIPTION_TEXT), nil]];
            return NO;
        }
    } else if ([key isEqualToString:@"location"]) {
        if (!self.longitude || !self.latitude) {
            *error = [NSError errorWithDomain:LOCATION_INVALID_TEXT code:2001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LOCATION_INVALID_DESCRIPTION_TEXT, LOCATION_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        }
    }
    return YES;
}

@end
