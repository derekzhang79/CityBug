//
//  ODMDescriptionFormViewController.h
//  OpendreamBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ODMDescriptionFormViewController : UIViewController<UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bugImageView;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UITextField *descTextFieleld;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;


@property (weak, nonatomic) UIImage *bugImage;

- (IBAction)doneButtonTapped:(id)sender;

@end
