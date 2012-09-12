//
//  ODMDescriptionViewController.h
//  OpendreamBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ODMDescriptionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *bugImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *catergoryLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;


- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)addCommentButtonTapped:(id)sender;


@end
