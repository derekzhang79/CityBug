//
//  ODMComment.h
//  CityBug
//
//  Created by Pirapa on 9/25/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

@class ODMUser;

@interface ODMComment : NSObject {
    NSString *_text, *_reportID;
    NSDate *_lastModified;
    ODMUser *_user;
}

@property (nonatomic, strong) NSString *text, *reportID;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) ODMUser *user;

@end
