//
//  ODMUserListTableViewController.h
//  CityBug
//
//  Created by tua~* on 10/10/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ODMReport;

@interface ODMUserListTableViewController : UITableViewController
{
    NSArray *_datasource;
    ODMReport *_report;
}
@property (nonatomic, readonly, strong) NSArray *datasource;
@property (nonatomic, strong) ODMReport *report;
@end
