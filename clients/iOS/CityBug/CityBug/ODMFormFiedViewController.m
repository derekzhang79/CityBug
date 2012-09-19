//
//  ODMFormFiedViewController.m
//  CityBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMFormFiedViewController.h"

@implementation ODMFormFiedViewController

@synthesize delegate;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (IBAction)CategoryButtonTapped:(id)sender {
}

- (IBAction)save:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(updateFormField:withTextField:)]) {
        [self.delegate updateFormField:self withTextField:nil];
    }
}

- (void)viewDidUnload {
    [self setTitleTextView:nil];
    [self setNoteTextView:nil];
    [super viewDidUnload];
}
@end
