//
//  ODMComment.h
//  CityBug
//
//  Created by Pirapa on 9/25/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODMUser.h"

@interface ODMComment : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) ODMUser *user;

@end
