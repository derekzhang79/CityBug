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

#define ROW_HEIGHT 44

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
    
    [self calculateContentSizeForScrollView];
}

-(void)setTableViewSize
{
    CGRect tvFrame = [self.tableView frame];

    [self.tableView setFrame:CGRectMake(tvFrame.origin.x, tvFrame.origin.y, tvFrame.size.width, 44 * [self.report.comments count])];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 44 * [self.report.comments count] + self.scrollView.frame.size.height)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
    
    ODMReportCommentViewController *reportComment = [[ODMReportCommentViewController alloc] init];
    reportComment.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    // Show or hide keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentForm:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCommentForm:) name:UIKeyboardWillHideNotification object:nil];
    
    [self calculateContentSizeForScrollView];
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

- (void)calculateContentSizeForScrollView
{
    //
    // Comments Height
    //
    NSUInteger numberOfComments = self.report.comments.count;
    CGSize commentsSize = CGSizeMake(self.tableView.bounds.size.width, numberOfComments * ROW_HEIGHT);
    
    //
    // Note height
    //
    CGSize noteSize = [self.noteLabel.text sizeWithFont:[UIFont systemFontOfSize:14.f] forWidth:self.noteLabel.bounds.size.width lineBreakMode:UILineBreakModeWordWrap];
    self.noteLabel.frame = CGRectMake(self.noteLabel.frame.origin.x, self.noteLabel.frame.origin.y, noteSize.width, noteSize.height);
    
    CGRect infoFrame = self.infoView.frame;
    
    // Value from Storyboard
    CGFloat defaultNoteLabelHeight = 22;
    CGFloat defaultInfoViewHeight = 322;
    CGFloat spaceBetweenInfoAndNote = 15;
    
    if (abs(self.noteLabel.frame.size.height - defaultNoteLabelHeight) > 0) {
        infoFrame.size.height = defaultInfoViewHeight + self.noteLabel.frame.size.height;
    } else {
        infoFrame.size.height = defaultInfoViewHeight;
    }
    
    //
    // Combine
    //
    CGRect contentFrame = self.scrollView.frame;
    contentFrame.size.height = infoFrame.size.height + spaceBetweenInfoAndNote + commentsSize.height;
    
    //
    //
    //
    self.scrollView.contentSize = CGSizeMake(contentFrame.size.width, contentFrame.size.height);
}
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
    ODMComment *commentObject = [[ODMComment alloc] init];
    
    [commentObject setText:self.commentTextField.text];
    [commentObject setReportID:self.report.uid];
    
    [[ODMDataManager sharedInstance] postComment:commentObject];
}

#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self resignFirstResponder];
}

- (void)showCommentForm:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height - keyboardSize.height;
        self.commentFormView.frame = newFrame;
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        [self.scrollView setContentInset:edgeInsets];
    }];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, self.scrollView.bounds.size.height, 1, 1) animated:YES];
}

- (void)hideCommentForm:(NSNotification *)notification
{
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height;
        self.commentFormView.frame = newFrame;
        [self.scrollView setContentInset:UIEdgeInsetsZero];
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d", [self.report.comments count]);
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}
@end
