//
//  ODMHelper.h
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#define BASE_URL @"http://127.0.0.1:3003"
//#define BASE_URL @"http://54.251.32.49:3003"
#define API_LIST @"/api/entries"

////////////////////////////////////////////////////////////////////////////////////////////////
#define DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"
////////////////////////////////////////////////////////////////////////////////////////////////
#define MAXIMUM_REPORT_LENGTH 256
#define MAXIMUM_NOTE_LENGTH 1024
#define VALIDATION_USERNAME_REGEXR @"^[a-zA-Z0-9ก-ฮเ-ไ]{1}[a-zA-Z0-9ก-๙]{2}[a-zA-Z0-9ก-๙ _]*"
#define VALIDATION_TITLE_REGEXR @"^[a-zA-Z0-9ก-ฮเ-ไ]{1}[a-zA-Z0-9ก-๙]{2}[a-zA-Z0-9ก-๙ _]*"
////////////////////////////////////////////////////////////////////////////////////////////////

// Title
#define TITLE_INVALID_TEXT @"Title does not valid."
#define TITLE_INVALID_DESCRIPTION_TEXT @"Please use only letters (a-z, A-Z, ก-ฮ), numbers, periods or whitespace"
#define TITLE_LENGTH_INVALID_TEXT TITLE_INVALID_TEXT
#define TITLE_LENGTH_INVALID_DESCRIPTION_TEXT @"Title should be less than 256 characters"
// Note
#define LONG_LENGTH_STRING_ERROR_DOMAIN @"Title should be less than 1024 characters"
#define LONG_LENGTH_STRING_ERROR_DESCRIPTION_TEXT LONG_LENGTH_STRING_ERROR_DOMAIN
// Location
#define LOCATION_INVALID_TEXT @"Location services Error"
#define LOCATION_INVALID_DESCRIPTION_TEXT @"Location service could not acquire your location"
////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * ODMLog
 */
#define ODMLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);