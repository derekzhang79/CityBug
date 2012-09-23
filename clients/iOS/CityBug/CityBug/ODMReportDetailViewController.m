//
//  ODMReportDetailViewController.m
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReportDetailViewController.h"

@interface ODMReportDetailViewController ()

@end

@implementation ODMReportDetailViewController {
    int numberOfComment;
}
@synthesize noteLabel;
@synthesize amountInLabel;
@synthesize locationLabel;


- (void)reloadData
{
//    double latitude = [[self.entry objectForKey:@"latitude"] doubleValue];
//    double longitude = [[self.entry objectForKey:@"longitude"] doubleValue];
    double latitude = 134.567;
    double longitude = 98.111;
    NSString *location;
    
    if (latitude > 0 && longitude > 0) {
        location = [NSString stringWithFormat:@"%1.3f, %1.3f", latitude, longitude];
    } else {
        location = @"";
    }
    
    //    NSString *imagePath = [BASE_URL stringByAppendingString:[self.entry objectForKey:@"full_image"]];
    //    [self.bugImageView setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"process"]];
    self.noteLabel.text = @"Biscuit brownie caramels apple pie wafer";
    self.locationLabel.text = location;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    numberOfComment = 0;
    [self reloadData];
}

- (void)viewDidUnload
{
    [self setNoteLabel:nil];
    [self setAmountInLabel:nil];
    [self setLocationLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [NSString stringWithFormat:@"Title: %@", [self.entry objectForKey:@"title"]];
    } else if (section == 1) {
        return @"test2";
    }

}


- (IBAction)addCommentButtonTapped:(id)sender {
}
@end
