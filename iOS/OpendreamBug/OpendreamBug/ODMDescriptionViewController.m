//
//  ODMDescriptionViewController.m
//  OpendreamBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMDescriptionViewController.h"
#import "UIImageView+AFNetworking.h"

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
    NSLog(@"entry %@", self.entry);
    
    NSString *location = [NSString stringWithFormat:@"%@, %@",[self.entry objectForKey:@"latitude"], [self.entry objectForKey:@"longitude"]];
    
    NSString *imagePath = [BASE_URL stringByAppendingString:[self.entry objectForKey:@"full_image"]];
    [self.bugImageView setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"process"]];
    
    self.descTextView.text = [self.entry objectForKey:@"title"];
    self.locationLabel.text = location;
    self.catergoryLabel.text = [self.entry objectForKey:@"categories"];
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


@end
