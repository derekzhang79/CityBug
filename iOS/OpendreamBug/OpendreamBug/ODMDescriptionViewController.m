//
//  ODMDescriptionViewController.m
//  OpendreamBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMDescriptionViewController.h"

@interface ODMDescriptionViewController ()

@end

@implementation ODMDescriptionViewController
@synthesize bugImageView;
@synthesize locationLabel;
@synthesize catergoryLabel;
@synthesize descTextView;

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
}

- (void)viewDidUnload
{
    [self setBugImageView:nil];
    [self setLocationLabel:nil];
    [self setCatergoryLabel:nil];
    [self setDescTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addCommentButtonTapped:(id)sender
{
}
@end
