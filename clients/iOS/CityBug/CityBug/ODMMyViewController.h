//
//  ODMMyViewController.h
//  CityBug
//
//  Created by Pirapa on 10/3/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ODMMyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *mySubcribeButton;
@property (weak, nonatomic) IBOutlet UITableView *myReportTableView;
@property (nonatomic, weak) IBOutlet UIView *noResultView;

@end
