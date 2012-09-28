//
//  ODMReportDetailViewController.m
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "UIImageView+WebCache.h"
#import "NSDate+HumanizedTime.h"

#import "ODMReportDetailViewController.h"
#import "ODMDataManager.h"

#define ROW_HEIGHT 44

@implementation ODMReportDetailViewController {
    NSUInteger numberOfComments;
    NSUInteger cooldownSendButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Report", @"Report");
    
    self.commentTextField.placeholder = NSLocalizedString(@"Enter comment here", @"Enter comment here");
    // Show or hide keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentForm:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCommentForm:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incommingComments:) name:ODMDataManagerNotificationReportsLoadingFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComment:) name:ODMDataManagerNotificationCommentLoadingFinish object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (BOOL)resignFirstResponder
{
    [self.commentTextField resignFirstResponder];    
    [self hideCommentForm:nil];
    
    return [super resignFirstResponder];
}

#pragma mark - Datasource

- (void)reloadData
{
    if (!self.report) return;
    
    self.titleLabel.text = [self.report title];
    self.userLabel.text = [self.report.user username];
    self.lastModifiedLabel.text = [self.report.lastModified stringWithHumanizedTimeDifference];
    self.iminLabel.text = [NSString stringWithFormat:@"%i",self.report.iminCount.intValue];
    self.locationLabel.text = [self.report.place title];
    self.noteLabel.text = [NSString stringWithFormat:@"%@", [self.report note]];
    
    // Report Image
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.report fullImage]]];
    [self.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    
    // Avatar Image
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.report.user uid]]];
    [self.avatarImageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    
    [self calculateContentSizeForScrollView];
    
    [self.tableView reloadData];
}

- (void)calculateContentSizeForScrollView
{
    if (!self.report) return;
    
    //
    // Comments Height
    //
    CGRect tvFrame = [self.tableView frame];
    numberOfComments = self.report.comments.count;
    CGSize commentsSize = CGSizeMake(self.tableView.bounds.size.width, numberOfComments * ROW_HEIGHT);
    [self.tableView setFrame:CGRectMake(tvFrame.origin.x, tvFrame.origin.y, tvFrame.size.width, ROW_HEIGHT * numberOfComments)];
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
    // Scroll to bottom
    //
    self.scrollView.contentSize = CGSizeMake(contentFrame.size.width, contentFrame.size.height);
}

- (void)setReport:(ODMReport *)report
{
    ODMLog(@"set new report");
    if (!report) return;
    
    _report = report;
    
    [self reloadData];
}

#pragma mark - Notifications

- (void)incommingComments:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        NSArray *datasource = (NSArray *)[notification object];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", self.report.uid];
        NSArray *filterByReport = [datasource filteredArrayUsingPredicate:predicate];
        if ([filterByReport count] > 0) {
            id obj = [filterByReport lastObject];
            if ([obj isKindOfClass:[ODMReport class]]) {
                _report = obj;
            }
            
            int incomingComments = (self.report.comments.count - numberOfComments);
            if (incomingComments > 0) {
                NSString *newCommentsString = @"";
                newCommentsString = (incomingComments == 1) ?
                [NSString stringWithFormat:NSLocalizedString(@"New 1 comment", @"New 1 comment")] :
                [NSString stringWithFormat:NSLocalizedString(@"New %i comments", @"New %i comments"), incomingComments];
                
                ODMLog(@"%@", newCommentsString);
                
                CGRect scrollRect = CGRectMake(0, self.scrollView.contentSize.height + self.commentFormView.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                [self.scrollView scrollRectToVisible:scrollRect animated:YES];
                
                ODMLog(@"Scroll to last %@", NSStringFromCGRect(scrollRect));
            }
            [self reloadData];
        }
    }
}

- (void)updateComment:(NSString *)comment
{
    // For beta version
    // We enforce user to reload all contents from server
    // Thus, we have to reload comments after
    // reports has completely parsed
    [[ODMDataManager sharedInstance] reports];
}

#pragma mark - FormField Delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reportMapSegue"]) {
//        UIViewController *vc = segue.destinationViewController;
//        UILabel *locationLabel = (UILabel *)[vc.view viewWithTag:6110];
//        locationLabel.text = [self.report.place title];
//        MKMapView *mapView = (MKMapView *)[vc.view viewWithTag:6111];
//        [mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.report.latitude.doubleValue, self.report.longitude.doubleValue) animated:NO];
    }
}

- (void)cooldownSendAction:(NSTimer *)timer;
{
    if (--cooldownSendButton == 0) {
        [timer invalidate];
        [self.sendButton setEnabled:YES];
    }
}

- (IBAction)addCommentButtonTapped:(id)sender
{
    if (!self.report) return;
    
    [self resignFirstResponder];
    @try {
        ODMComment *commentObject = [[ODMComment alloc] init];
        [commentObject setText:self.commentTextField.text];
        [commentObject setReportID:self.report.uid];
        
        NSError *error = nil;
        [[ODMDataManager sharedInstance] postComment:commentObject withError:&error];
        if (error) {
            @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        }
        
        self.commentTextField.text = @"";
        [self.sendButton setEnabled:NO];
        cooldownSendButton = 3;
        [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(cooldownSendAction:) userInfo:nil repeats:YES];
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CityBug", @"CityBug") message:[exception reason] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        
        [alertView show];
    }
}

#pragma mark - UIScrollView

- (void)showCommentForm:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height - keyboardSize.height;
        self.commentFormView.frame = newFrame;
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height + self.commentFormView.frame.size.height , 0);
        [self.scrollView setContentInset:edgeInsets];
    }];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, self.scrollView.contentSize.height, 1, 1) animated:YES];
}

- (void)hideCommentForm:(NSNotification *)notification
{
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height;
        self.commentFormView.frame = newFrame;
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.scrollView setContentInset:edgeInsets];
    }];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, self.scrollView.contentSize.height, 1, 1) animated:YES];
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
    cell.textLabel.text = [comment.user username];
    cell.detailTextLabel.text = [comment text];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

@end
