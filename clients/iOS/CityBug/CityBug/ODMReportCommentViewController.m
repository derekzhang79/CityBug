//
//  ODMReportCommentViewController.m
//  CityBug
//
//  Created by Pirapa on 9/24/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReportCommentViewController.h"
#import "ODMDataManager.h"
#import "ODMComment.h"

@interface ODMReportCommentViewController ()

@end

@implementation ODMReportCommentViewController
@synthesize CommentTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setCommentTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)DoneButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(updateComment:)]) {
        [self.delegate updateComment:self.CommentTextField.text];
    }
    
}

@end
