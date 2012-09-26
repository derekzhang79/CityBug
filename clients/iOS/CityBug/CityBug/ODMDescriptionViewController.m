//
//  ODMDescriptionViewController.m
//  CityBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMDescriptionViewController.h"

@implementation ODMDescriptionViewController

#pragma mark -

- (void)reloadData
{
    double latitude = [[self.entry objectForKey:@"latitude"] doubleValue];
    double longitude = [[self.entry objectForKey:@"longitude"] doubleValue];
    NSString *location;
    
        location = [NSString stringWithFormat:@"%1.3f, %1.3f", latitude, longitude];
    
//    NSString *imagePath = [BASE_URL stringByAppendingString:[self.entry objectForKey:@"full_image"]];
//    [self.bugImageView setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"process"]];
    self.descTextView.text = [self.entry objectForKey:@"title"];
    self.locationLabel.text = location;
    self.catergoryLabel.text = [self.entry objectForKey:@"categories"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

- (void)viewDidUnload
{
    [self setBugImageView:nil];
    [self setLocationLabel:nil];
    [self setCatergoryLabel:nil];
    [self setDescTextView:nil];
    [super viewDidUnload];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
