//
//  ODMReportDetailViewController.m
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReportDetailViewController.h"

@implementation ODMReportDetailViewController {
    int numberOfComment;
    NSMutableDictionary *commentDict;
    NSMutableArray *commentArray;
}

@synthesize reportImageView;
@synthesize titleLabel;
@synthesize locationLabel;
@synthesize CommentLabel;



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

    self.titleLabel.text = @"Biscuit brownie caramels apple pie wafer";
    self.locationLabel.text = location;

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

    [self setLocationLabel:nil];
    [self setReportImageView:nil];
    [self setTitleLabel:nil];
    [self setCommentLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - FormField Delegate

- (void)updateComment:(NSString *)comment
{
    NSLog(@"Comment %@", comment);
    [commentDict setObject:comment forKey:@"comment"];
    [commentDict setObject:@"Plloy" forKey:@"user"];
    [commentArray addObject:commentDict];
    self.CommentLabel.text = comment;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"commentSegue"]) {
        ODMReportCommentViewController *commentVC = segue.destinationViewController;
        commentVC.delegate = self;
    }
}
- (IBAction)addCommentButtonTapped:(id)sender {
}
@end
