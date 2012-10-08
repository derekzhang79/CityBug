//
//  ODMReportDetailViewController.h
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReport.h"

@interface ODMReportDetailViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    __weak UITableView *_tableView;
    
    ODMReport *_report;
}

/*
 * Information including comments
 */
@property (nonatomic, strong) ODMReport *report;

/*
 * View
 */
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

/*
 * Accessory
 */
@property (weak, nonatomic) IBOutlet UIView *commentFormView, *infoView, *backView;;
@property (weak, nonatomic) IBOutlet UIImageView *reportImageView, *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel, *locationLabel, *commentLabel, *iminLabel, *userLabel, *createdAtLabel, *noteLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
/*
 * Add comment
 */
- (IBAction)addCommentButtonTapped:(id)sender;

@end

