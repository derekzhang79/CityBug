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

#import "NSDate+HumanizedTime.h"

#import "ODMDataManager.h"

#import <MapKit/MapKit.h>

@implementation ODMReportDetailViewController

- (void)reloadData
{
    self.titleLabel.text = self.report.title;
    self.userLabel.text = self.report.user.username;
    self.lastModifiedLabel.text = [self.report.lastModified stringWithHumanizedTimeDifference];
    self.iminLabel.text = [NSString stringWithFormat:@"%i",self.report.iminCount.intValue];
    self.locationLabel.text = self.report.place.title;
    self.noteLabel.text = self.report.note;
    
    // Report Image
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.report fullImage]]];
    [self.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    
    // Avatar Image
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.report.user uid]]];
    [self.avatarImageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
    
    ODMReportCommentViewController *reportComment = [[ODMReportCommentViewController alloc] init];
    reportComment.delegate = self;

    // Show or hide keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentForm:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCommentForm:) name:UIKeyboardWillHideNotification object:nil];

}

- (BOOL)resignFirstResponder
{
    [self.commentTextField resignFirstResponder];
    
    [self hideCommentForm:nil];
    
    return [super resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Datasource

- (void)setReport:(ODMReport *)report
{
    _report = report;
    
    [self reloadData];
}

#pragma mark - FormField Delegate

- (void)updateComment:(NSString *)comment
{
    self.commentLabel.text = comment;
 
    ODMComment *commentObject = [[ODMComment alloc] init];

    [commentObject setText:comment];
    [commentObject setReportID:self.report.uid];
//    [self.entry addComment:commentObject];
    
    [[ODMDataManager sharedInstance] postComment:commentObject];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"commentSegue"]) {
        ODMReportCommentViewController *commentVC = segue.destinationViewController;
        commentVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"reportMapSegue"]) {
        UIViewController *vc = segue.destinationViewController;
        UILabel *locationLabel = (UILabel *)[vc.view viewWithTag:6110];
        locationLabel.text = [self.report.place title];
        MKMapView *mapView = (MKMapView *)[vc.view viewWithTag:6111];
        [mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.report.latitude.doubleValue, self.report.longitude.doubleValue) animated:NO];
        
    }
}

- (IBAction)addCommentButtonTapped:(id)sender
{
    [self resignFirstResponder];
}

#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self resignFirstResponder];
}

- (void)showCommentForm:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3f animations:^{
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height - keyboardSize.height;
        self.commentFormView.frame = newFrame;
    }];
}

- (void)hideCommentForm:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height;
        self.commentFormView.frame = newFrame;
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.report.comments count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CommentCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    ODMComment *comment = [self.report.comments objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.report.user username];
    cell.detailTextLabel.text = [comment text];
    
    return cell;
}

@end
