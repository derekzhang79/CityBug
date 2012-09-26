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
        self.comments = [NSMutableArray new];
    }
    return self;
}

+ (ODMReport *)newReportWithTitle:(NSString *)title note:(NSString *)note
{
    return [[self alloc] initWithTitle:title note:note];
}

- (NSString *)iminString
{
    if (self.iminCount.intValue <= 0) {
        return [NSString stringWithFormat:@"Nobody is in yet."];
    } else if (self.iminCount.intValue == 1) {
        return [NSString stringWithFormat:@"%i's in", self.iminCount.intValue];
    }
    return [NSString stringWithFormat:@"%i're in", self.iminCount.intValue];
}

- (void)addComment:(ODMComment *) comment
{
    [self.comments addObject:comment];
}

/*
 * Validate title field
 */
- (BOOL)validateTitleField:(NSString *)title
{
    //NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VALIDATION_TITLE_REGEXR];
    //NSString *string = title;
    //return [myTest evaluateWithObject:string];
    return YES;
}

- (BOOL)validateLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude
{
    double lat = [latitude doubleValue];
    double lng = [longitude doubleValue];
    
    if (lat < -90.f || lat > 90.f) {
        return NO;
    } else if (lng < -180.f || lng > 180.f) {
        return NO;
    }
    return YES;
}

- (BOOL)validateLocationWithLatitude:(NSNumber *)latitude
{
    double lat = [latitude doubleValue];
    
    if (lat < -90.f || lat > 90.f) {
        return NO;
    }
    return YES;
}

- (BOOL)validateLocationWithLongitude:(NSNumber *)longitude
{
    double lng = [longitude doubleValue];
    
    if (lng < -180.f || lng > 180.f) {
        return NO;
    }
    return YES;
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
    /*
    if ([key isEqualToString:@"title"]) {
        
        if ([*value length] < MINIMUN_REPORT_LENGTH) {
            *error = [NSError errorWithDomain:TITLE_INVALID_REQUIRE_TEXT code:1001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(TITLE_INVALID_REQUIRE_DESCRIPTION_TEXT, TITLE_INVALID_REQUIRE_DESCRIPTION_TEXT), nil]];
            return NO;
        }
        else if ([*value length] > MAXIMUM_REPORT_LENGTH) {
            *error = [NSError errorWithDomain:TITLE_INVALID_TEXT code:1002 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(TITLE_INVALID_DESCRIPTION_TEXT, TITLE_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        } else if (![self validateTitleField:*value]) {
            *error = [NSError errorWithDomain:TITLE_LENGTH_INVALID_TEXT code:1003 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(TITLE_LENGTH_INVALID_DESCRIPTION_TEXT, TITLE_LENGTH_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        }
        
    } else */
    if ([key isEqualToString:@"note"]) {
        if ([*value length] > MAXIMUM_REPORT_LENGTH) {
            *error = [NSError errorWithDomain:LONG_LENGTH_STRING_ERROR_DOMAIN code:1004 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LONG_LENGTH_STRING_ERROR_DESCRIPTION_TEXT, LONG_LENGTH_STRING_ERROR_DESCRIPTION_TEXT), nil]];
            return NO;
        }
    } else if ([key isEqualToString:@"latitude"]) {
        if (!value) {
            *error = [NSError errorWithDomain:LOCATION_INVALID_TEXT code:2001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LOCATION_INVALID_DESCRIPTION_TEXT, LOCATION_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        } else if (![self validateLocationWithLatitude:*value]) {
            *error = [NSError errorWithDomain:LOCATION_VALUE_INVALID_TEXT code:2001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LOCATION_VALUE_INVALID_DESCRIPTION_TEXT, LOCATION_VALUE_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        }
    } else if ([key isEqualToString:@"longitude"]) {
        if (!value) {
            *error = [NSError errorWithDomain:LOCATION_INVALID_TEXT code:2001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LOCATION_INVALID_DESCRIPTION_TEXT, LOCATION_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        } else if (![self validateLocationWithLongitude:*value]) {
            *error = [NSError errorWithDomain:LOCATION_VALUE_INVALID_TEXT code:2001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LOCATION_VALUE_INVALID_DESCRIPTION_TEXT, LOCATION_VALUE_INVALID_DESCRIPTION_TEXT), nil]];
            return NO;
        }
    } else if ([key isEqualToString:@"place"]) {
        if (*value == NULL) {
            *error = [NSError errorWithDomain:PLACE_IS_REQUIRED_FIELD_TEXT code:3001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(PLACE_IS_REQUIRED_FIELD_DESCRIPTION_TEXT, PLACE_IS_REQUIRED_FIELD_DESCRIPTION_TEXT), nil]];
            return NO;
        }
    }
    
    return YES;
}

@end
