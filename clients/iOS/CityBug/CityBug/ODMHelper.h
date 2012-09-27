//
//  ODMHelper.h
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#define BASE_URL @"http://127.0.0.1:3003"
//#define BASE_URL @"http://54.251.32.49:3003"

#define DEBUG_HAS_SIGNED_IN YES

////////////////////////////////////////////////////////////////////////////////////////////////
#define DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"
////////////////////////////////////////////////////////////////////////////////////////////////

#define LOCATION_SEARCH_THRESHOLD 3

////////////////////////////////////////////////////////////////////////////////////////////////
#define MINIMUN_REPORT_LENGTH 4
#define MAXIMUM_REPORT_LENGTH 256
#define MAXIMUM_NOTE_LENGTH 1024
#define VALIDATION_USERNAME_REGEXR @"^[a-zA-Z0-9ก-ฮเ-ไ]{1}[a-zA-Z0-9ก-๙]{2}[a-zA-Z0-9ก-๙ _]*"
#define VALIDATION_TITLE_REGEXR @"^\w.*(?<=^|>)[^><]+?(?=<|$)"
////////////////////////////////////////////////////////////////////////////////////////////////

// Title
#define TITLE_INVALID_TEXT @"Title does not valid."
#define TITLE_INVALID_REQUIRE_TEXT @"Title is required"
#define TITLE_INVALID_REQUIRE_DESCRIPTION_TEXT @"Please fill in title field for report"

#define TITLE_INVALID_DESCRIPTION_TEXT @"Please use only letters (a-z, A-Z, ก-ฮ), numbers, periods or whitespace"
#define TITLE_LENGTH_INVALID_TEXT TITLE_INVALID_TEXT
#define TITLE_LENGTH_INVALID_DESCRIPTION_TEXT @"Title should be less than 256 characters"

// Note
#define LONG_LENGTH_STRING_ERROR_DOMAIN @"Title should be less than 1024 characters"
#define LONG_LENGTH_STRING_ERROR_DESCRIPTION_TEXT LONG_LENGTH_STRING_ERROR_DOMAIN
// Location
#define LOCATION_INVALID_TEXT @"Location services Error"
#define LOCATION_INVALID_DESCRIPTION_TEXT @"Location services could not acquire your location"

#define LOCATION_VALUE_INVALID_TEXT @"Latitude/Longitude error"
#define LOCATION_VALUE_INVALID_DESCRIPTION_TEXT @"Invalid latitude or longitude value. Latitude should valid in range (-90,90) and longitude should valid in range (-180, 180)"

#define REQUIRE_LOCATION_SERVICES_TEXT @"Require location servcies"

#define PLACE_IS_REQUIRED_FIELD_TEXT @"Require place"
#define PLACE_IS_REQUIRED_FIELD_DESCRIPTION_TEXT @"Please select a place for this report"

////////////////////////////////////////////////////////////////////////////////////////////////

#define USER_CURRENT_LOCATION @"currentLocation"
#define MINIMUN_ACCURACY_DISTANCE 50

////////////////////////////////////////////////////////////////////////////////////////////////

#define COOLDOWN_SEARCH_INTERVAL 3

////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * ODMLog
 */
#define ODMLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

// Report
extern NSString *ODMDataManagerNotificationReportsLoadingFinish;
extern NSString *ODMDataManagerNotificationReportsLoadingFail;
// Category
extern NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
extern NSString *ODMDataManagerNotificationCategoriesLoadingFail;
// Place
extern NSString *ODMDataManagerNotificationPlacesLoadingFinish;
extern NSString *ODMDataManagerNotificationPlacesSearchingFinish;
extern NSString *ODMDataManagerNotificationPlacesLoadingFail;

// Form
extern NSString *ODMDataManagerDidPostingReportFinish;
extern NSString *ODMDataManagerDidPostingReportUpload;