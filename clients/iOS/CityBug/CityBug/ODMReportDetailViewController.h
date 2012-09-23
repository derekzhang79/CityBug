//
//  ODMReportDetailViewController.h
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ODMReportDetailViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountInLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) NSDictionary *entry;

- (IBAction)addCommentButtonTapped:(id)sender;

@end
