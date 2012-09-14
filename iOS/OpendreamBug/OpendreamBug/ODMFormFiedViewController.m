//
//  ODMFormFiedViewController.m
//  OpendreamBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMFormFiedViewController.h"

@implementation ODMFormFiedViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.formTextField becomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [self.formTextField becomeFirstResponder];
    
    return [super becomeFirstResponder];
}

- (IBAction)save:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    ODMLog(@"formTextField %@", self.formTextField);
    
    if ([self.delegate respondsToSelector:@selector(updateFormField:withTextField:)]) {
        [self.delegate updateFormField:self withTextField:self.formTextField];
    }
}

@end
