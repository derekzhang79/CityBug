//
//  ODMReportDetailViewController.h
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReportCommentViewController.h"
#import "ODMReport.h"

@interface ODMReportDetailViewController : UIViewController <UITextFieldDelegate, ODMReportCommentDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    UITableView *_tableView;
    
    ODMReport *_report;
}

/*
 * Information including comments
 */
@property (nonatomic, strong) ODMReport *report;

/*
 * View
 */
@property (nonatomic, strong) IBOutlet UITableView *tableView;

/*
 * Accessory
 */
@property (weak, nonatomic) IBOutlet UIView *commentFormView;
@property (weak, nonatomic) IBOutlet UIImageView *reportImageView, *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel, *locationLabel, *commentLabel, *iminLabel, *userLabel, *lastModifiedLabel, *noteLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

/*
 * Add comment
 */
- (IBAction)addCommentButtonTapped:(id)sender;

@end

