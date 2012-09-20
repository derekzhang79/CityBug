//
//  ODMDescriptionFormViewController.h
//  CityBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMFormFiedViewController.h"
#import "ODMCategoryListViewController.h"

@interface ODMDescriptionFormViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, ODMFormFieldDelegate, ODMCategoryListDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bugImageView;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField, *noteTextField;

@property (weak, nonatomic) UIImage *bugImage;

- (IBAction)doneButtonTapped:(id)sender;

@end
