//
//  ODMDescriptionFormViewController.h
//  OpendreamBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ODMDescriptionFormViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *bugImageView;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) UIImage *bugImage;

- (IBAction)doneButtonTapped:(id)sender;

@end
