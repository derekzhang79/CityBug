//
//  ODMComment.m
//  CityBug
//
//  Created by Pirapa on 9/25/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMComment.h"

@implementation ODMComment

- (BOOL)validateValue:(__autoreleasing id *)value forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    if ([key isEqualToString:@"text"]) {
        if ([(NSString *)*value length] <= MINIMUN_REPORT_LENGTH) {
            *error = [NSError errorWithDomain:COMMENT_INVALID_TEXT code:1001 userInfo:[NSDictionary dictionaryWithObject:COMMENT_INVALID_REQUIRE_DESCRIPTION_TEXT forKey:@"description"]];
            return NO;
        }
    }
    return YES;
}
@end
