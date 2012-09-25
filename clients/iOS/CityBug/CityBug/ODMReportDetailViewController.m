//
//  ODMReportDetailViewController.m
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReportDetailViewController.h"

#import "UIImageView+WebCache.h"
#import "ODMDataManager.h"

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
  
    double latitude = [[self.entry latitude] doubleValue];
    double longitude = [[self.entry longitude] doubleValue];
    NSString *location;
    
    if (latitude > 0 && longitude > 0) {
        location = [NSString stringWithFormat:@"%1.3f, %1.3f", latitude, longitude];
        NSLog(@"location %@", location);
    } else {
        location = @"";
    }

    self.titleLabel.text = [self.entry title];
    self.locationLabel.text = location;
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.entry fullImage]]];
    ODMLog(@"report URL %@",[reportURL absoluteString]);
    [self.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];

    

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

    self.CommentLabel.text = comment;
    ODMComment *commentObject = [[ODMComment alloc] init];
    [commentObject setText:comment];
    [commentObject setReportID:self.entry.uid];
    [[ODMDataManager sharedInstance] postComment:commentObject];
    
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
