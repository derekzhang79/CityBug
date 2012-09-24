//
//  ODMReportDetailViewController.h
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODMReportCommentViewController.h"




@interface ODMReportDetailViewController : UITableViewController<UITextFieldDelegate, ODMReportCommentDelegate>

@property (weak, nonatomic) IBOutlet UILabel *amountInLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) NSDictionary *entry;


@end
