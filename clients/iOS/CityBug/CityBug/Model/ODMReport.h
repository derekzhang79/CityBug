//
//  ODMReport.h
//  CityBug
//
//  Created by InICe on 19/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODMReport : NSObject {
    NSString *_title;
    NSString *_note;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *note;

@end
