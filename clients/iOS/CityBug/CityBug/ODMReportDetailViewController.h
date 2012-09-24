//
//  ODMReportDetailViewController.h
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReportCommentViewController.h"

@interface ODMReportDetailViewController : UIViewController<UITextFieldDelegate, ODMReportCommentDelegate>

@property (weak, nonatomic) NSDictionary *entry;
@property (weak, nonatomic) IBOutlet UIImageView *reportImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *CommentLabel;
- (IBAction)addCommentButtonTapped:(id)sender;

@end

