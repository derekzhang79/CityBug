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
#define DATA_UPDATING_INTERVAL_IN_SECOND 3
////////////////////////////////////////////////////////////////////////////////////////////////
#define MINIMUN_REPORT_LENGTH 4
#define MAXIMUM_REPORT_LENGTH 256

#define MINIMUM_COMMENT_LENGTH 2
#define MAXIMUM_COMMENT_LENGTH 1024

#define MAXIMUM_NOTE_LENGTH 1024
#define VALIDATION_TITLE_TEXT_REGEXR @"^[a-zA-Z0-9ก-ฮเ-ไ]{1}[a-zA-Z0-9ก-๙]{2}[a-zA-Z0-9ก-๙ _]*"
#define VALIDATION_USERNAME_REGEXR @"^[a-zA-Z0-9]{1}[a-zA-Z0-9_.]*"
#define VALIDATION_TITLE_REGEXR @"^\w.*(?<=^|>)[^><]+?(?=<|$)"
#define VALIDATION_EMAIL_REGEXR @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define MINIMUM_USER_LENGTH 3
#define MINIMUM_PASSWORD_LENGTH 6
#define MAXIMUM_USER_LENGTH 16
#define MAXIMUM_PASSWORD_LENGTH 16
////////////////////////////////////////////////////////////////////////////////////////////////

// Title
#define TITLE_INVALID_TEXT @"Title does not valid."
#define TITLE_INVALID_REQUIRE_TEXT @"Title is required"
#define TITLE_INVALID_REQUIRE_DESCRIPTION_TEXT @"Please fill in title field for report"

#define TITLE_INVALID_DESCRIPTION_TEXT @"Please use only letters (a-z, A-Z, ก-ฮ), numbers, periods or whitespace"
#define TITLE_LENGTH_INVALID_TEXT TITLE_INVALID_TEXT
#define TITLE_LENGTH_INVALID_DESCRIPTION_TEXT @"Title must be less than 256 characters"

// Comment
#define COMMENT_INVALID_TEXT @"Comment does not valid."
#define COMMENT_INVALID_SHORT_REQUIRE_DESCRIPTION_TEXT @"Comment text must contain at least 3 characters"
#define COMMENT_INVALID_LONG_REQUIRE_DESCRIPTION_TEXT @"Comment text must be less than 1024 characters"

// Note
#define LONG_LENGTH_STRING_ERROR_DOMAIN @"Title must be less than 1024 characters"
#define LONG_LENGTH_STRING_ERROR_DESCRIPTION_TEXT LONG_LENGTH_STRING_ERROR_DOMAIN

// Location
#define LOCATION_INVALID_TEXT @"Location services Error"
#define LOCATION_INVALID_DESCRIPTION_TEXT @"Location services could not acquire your location"

#define LOCATION_VALUE_INVALID_TEXT @"Latitude/Longitude error"
#define LOCATION_VALUE_INVALID_DESCRIPTION_TEXT @"Invalid latitude or longitude value. Latitude should valid in range (-90,90) and longitude should valid in range (-180, 180)"

#define REQUIRE_LOCATION_SERVICES_TEXT @"Require location services"

#define PLACE_IS_REQUIRED_FIELD_TEXT @"Require place"
#define PLACE_IS_REQUIRED_FIELD_DESCRIPTION_TEXT @"Please select a place for this report"

// sign up

#define SIGN_UP_USERNAME_INVALID_TEXT @"Username does not valid, please use only letters (a-z, A-Z), numbers, underscore or dot"
#define SIGN_UP_USERNAME_INVALID_LENGTH @"Username must contain at least 3 characters and must be less than 16 characters"
#define SIGN_UP_PASSWORD_LENGTH @"Password does not valid, password must contain at least 6 characters and must be less than 16 characters"

#define SIGN_UP_EMAIL_INVALID_TEXT @"Email does not valid"
#define SIGN_UP_CONFIRM_PASSWORD_INVALID_TEXT @"Password mismatch"

#define SIGN_UP_USERNAME_EXISTED @"Username is existed. Please try again"
#define SIGN_UP_EMAIL_EXISTED @"Email is existed. Please try again"

////////////////////////////////////////////////////////////////////////////////////////////////

#define USER_CURRENT_LOCATION @"currentLocation"
#define MINIMUN_ACCURACY_DISTANCE 50

////////////////////////////////////////////////////////////////////////////////////////////////

#define COOLDOWN_SEARCH_INTERVAL 3

////////////////////////////////////////////////////////////////////////////////////////////////

#define NOW_TABBAR @"nowTabBar"

////////////////////////////////////////////////////////////////////////////////////////////////

#define HEADER_TEXT_AUTHENTICATED @"authenticated"
#define HEADER_TEXT_USERNAME_EXISTED @"username existed"
#define HEADER_TEXT_EMAIL_EXISTED @"email existed"
#define HEADER_TEXT_SIGNUP_COMPLETE @"registered"
#define HEADER_TEXT_SUBSCRIBE_COMPLETE @"subscribed"
#define HEADER_TEXT_UNSUBSCRIBE_COMPLETE @"unsubscribed"
#define HEADER_TEXT_SUBSCRIBE_NOT_COMPLETE @"subscribed not complete"
#define HEADER_TEXT_UNSUBSCRIBE_NOT_COMPLETE @"unsubscribed not complete"
#define HEADER_TEXT_CAN_NOT_GET_REPORT_PLACE @"can not get reports place"
#define HEADER_TEXT_IMIN_ADD_COMPLETE @"imin add"
#define HEADER_TEXT_IMIN_DELETE_COMPLETE @"imin delete"
#define HEADER_TEXT_IMIN_EXISTED @"imin existed"

/*
 * ODMLog
 */
#define ODMLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

// Report
extern NSString *ODMDataManagerNotificationReportsLoadingFinish;
extern NSString *ODMDataManagerNotificationReportsLoadingFail;
// Comment
extern NSString *ODMDataManagerNotificationCommentLoadingFinish;
extern NSString *ODMDataManagerNotificationCommentLoadingFail;
// Category
extern NSString *ODMDataManagerNotificationCategoriesLoadingFinish;
extern NSString *ODMDataManagerNotificationCategoriesLoadingFail;
// Place
extern NSString *ODMDataManagerNotificationPlacesLoadingFinish;
extern NSString *ODMDataManagerNotificationPlacesSearchingFinish;
extern NSString *ODMDataManagerNotificationPlacesLoadingFail;
// My Subscription
extern NSString *ODMDataManagerNotificationMySubscriptionLoadingFinish;
extern NSString *ODMDataManagerNotificationMySubscriptionLoadingFail;

// Form
extern NSString *ODMDataManagerDidPostingReportFinish;
extern NSString *ODMDataManagerDidPostingReportUpload;

// Sign in
extern NSString *ODMDataManagerNotificationAuthenDidFinish;
// Sign up
extern NSString *ODMDataManagerNotificationSignUpDidFinish;

// My Report
extern NSString *ODMDataManagerNotificationMyReportsLoadingFinish;
extern NSString *ODMDataManagerNotificationMyReportsLoadingFail;

// Place Reports
extern NSString *ODMDataManagerNotificationPlaceReportsLoadingFinish;
extern NSString *ODMDataManagerNotificationPlaceReportsLoadingFail;

// Place Subscribe
extern NSString *ODMDataManagerNotificationPlaceSubscribeDidFinish;
extern NSString *ODMDataManagerNotificationPlaceSubscribeDidFail;

// Place Unsubscribe
extern NSString *ODMDataManagerNotificationPlaceUnsubscribeDidFinish;
extern NSString *ODMDataManagerNotificationPlaceUnsubscribeDidFail;

// imin

extern NSString *ODMDataManagerNotificationIminAddDidFinish;
extern NSString *ODMDataManagerNotificationIminDeleteDidFinish;
extern NSString *ODMDataManagerNotificationIminDidFail;
extern NSString *ODMDataManagerNotificationIminUsersLoadingFinish;
extern NSString *ODMDataManagerNotificationIminUsersLoadingFail;
extern NSString *ODMDataManagerNotificationIminDidLoading;

