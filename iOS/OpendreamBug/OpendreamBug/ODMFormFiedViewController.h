//
//  ODMFormFiedViewController.h
//  OpendreamBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

@protocol ODMFormFieldDelegate;

@interface ODMFormFiedViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *formTextField;

- (BOOL)becomeFirstResponder;

- (IBAction)save:(id)sender;

@end

@protocol ODMFormFieldDelegate <NSObject>

- (void)updateFormField:(ODMFormFiedViewController *)viewController withTextField:(UITextField *)textField;

@end