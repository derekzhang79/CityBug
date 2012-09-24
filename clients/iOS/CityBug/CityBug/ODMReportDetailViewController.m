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
    NSMutableDictionary *commentDict;
    NSMutableArray *commentArray;
}

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
//    self.noteLabel.text = @"Biscuit brownie caramels apple pie wafer";
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
    ODMReportCommentViewController *reportComment = [[ODMReportCommentViewController alloc] init];
    reportComment.delegate = self;
    commentDict = [[NSMutableDictionary alloc] init];
    commentArray = [[NSMutableArray alloc] init];
    
    [self updateComment:@"sampleComment"];
}

- (void)viewDidUnload
{
    [self setAmountInLabel:nil];
    [self setLocationLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRow = [commentArray count];
    return numberOfRow;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...

    cell.detailTextLabel.text = @"Wooo";
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *result = [NSString stringWithFormat:@"Title: %@", [self.entry objectForKey:@"title"]];
    if (section == 0)
    {
        return result;
    }
    return @"Comment";
}


- (IBAction)addCommentButtonTapped:(id)sender {
}

#pragma mark - FormField Delegate

- (void)updateComment:(NSString *)comment
{
    NSLog(@"Comment %@", comment);
    [commentDict setObject:comment forKey:@"comment"];
    [commentDict setObject:@"Plloy" forKey:@"user"];
    [commentArray addObject:commentDict];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"commentSegue"]) {
        ODMReportCommentViewController *commentVC = segue.destinationViewController;
        commentVC.delegate = self;
    }
}
@end
