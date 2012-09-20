//
//  ODMFormFiedViewController.h
//  CityBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

@protocol ODMFormFieldDelegate;

@interface ODMFormFiedViewController : UIViewController {
    __unsafe_unretained id <ODMFormFieldDelegate> delegate;
    
    NSArray *_datasource;
}

@property (unsafe_unretained) id <ODMFormFieldDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *titleTextView, *noteTextView;

- (IBAction)CategoryButtonTapped:(id)sender;
- (IBAction)save:(id)sender;

@end

@protocol ODMFormFieldDelegate <NSObject>

- (void)updateFormField:(ODMFormFiedViewController *)viewController withTextField:(UITextField *)textField;

@end