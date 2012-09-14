//
//  ODMHelper.h
//  OpendreamBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#define API_LIST_ENTRIES @"https://dl.dropbox.com/u/20163799/%5BDev%5DCityBug/entries.json"


//#define BASE_URL @"http://localhost:3003"
#define BASE_URL @"http://172.20.10.8:3003"
#define API_LIST @"/api/entries"

////////////////////////////////////////////////////////////////////////////////////////////////
#define DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"
////////////////////////////////////////////////////////////////////////////////////////////////
#define MAXIMUM_ENTRY_LENGTH 30
#define MAXIMUM_NOTE_LENGTH 1024
#define VALIDATION_USERNAME_REGEXR @"^[a-zA-Z0-9ก-ฮเ-ไ]{1}[a-zA-Z0-9ก-๙]{2}[a-zA-Z0-9ก-๙ _]*"
////////////////////////////////////////////////////////////////////////////////////////////////
#define NAME_INVALID_TITLE @"Name does not valid."
#define NAME_INVALID_STRING @"Please use only letters (a-z, A-Z, ก-ฮ), numbers, periods or whitespace"
#define NAME_LENGTH_INVALID @"Name should be less than 30 characters"
#define LONG_LENGTH_STRING_ERROR_DOMAIN @"title should be less than 1024 characters"
////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * ODMLog
 */
#define ODMLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);