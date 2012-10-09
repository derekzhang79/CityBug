//
//  ODMImin.h
//  CityBug
//
//  Created by nut hancharoernkit on 10/9/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//


@interface ODMImin : NSObject
{
    NSString *_reportID;    
    NSDate *_lastModified, *_createdAt;}

@property (nonatomic, strong) NSString *reportID;
@property (nonatomic, strong) NSDate *lastModified, *createdAt;

@end
