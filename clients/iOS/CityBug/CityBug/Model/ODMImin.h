//
//  ODMImin.h
//  CityBug
//
//  Created by nut hancharoernkit on 10/9/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//
@class ODMUser;

@interface ODMImin : NSObject
{
    NSString *_reportID;    
    NSDate *_lastModified, *_createdAt;
    ODMUser *_user;
}

@property (nonatomic, strong) NSString *reportID;
@property (nonatomic, strong) NSDate *lastModified, *createdAt;
@property (nonatomic, strong) ODMUser *user;

@end
