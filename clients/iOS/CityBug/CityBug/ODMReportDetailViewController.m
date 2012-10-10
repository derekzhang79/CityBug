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

#import "ODMImin.h"
#import "ODMReportDetailViewController.h"
#import "ODMDataManager.h"

#define ROW_HEIGHT 44
#define TABLE_VIEW_ORIGIN_X 337

@implementation ODMReportDetailViewController {
    NSUInteger numberOfComments;
    NSUInteger cooldownSendButton;
    NSUInteger cooldownSendImin;
}

#pragma mark - View LifeCycle

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCommentView:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComment:) name:ODMDataManagerNotificationIminAddDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComment:) name:ODMDataManagerNotificationIminDeleteDidFinish object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.backView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture2];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateCommentView:nil];

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

- (void)handleTapGesture:(UIGestureRecognizer *)gesture
{
    [self resignFirstResponder];
}

- (void)updateCommentView:(NSNotificationCenter *)noti
{
    BOOL isAuthen = [[ODMDataManager sharedInstance] isAuthenticated];
    
    if (isAuthen) {
        self.commentFormView.hidden = NO;
        self.iminImage.userInteractionEnabled = YES;
        [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 323)];
        
    } else {
        self.commentFormView.hidden = YES;
        self.iminImage.userInteractionEnabled = NO;
        [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

#pragma mark - Datasource

- (void)reloadData
{
    if (!self.report) return;
    
    self.titleLabel.text = [self.report title];
    self.userLabel.text = [self.report.user username];
    self.createdAtLabel.text = [self.report.createdAt stringWithHumanizedTimeDifference];
    self.iminLabel.text = [NSString stringWithFormat:@"%i",self.report.iminCount.intValue];
    self.locationLabel.text = [self.report.place title];
    self.noteLabel.text = [NSString stringWithFormat:@"%@", [self.report note]];
    
    // Report Image
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.report fullImage]]];
    [self.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    
    // Avatar Image
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.report.user uid]]];
    [self.avatarImageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"1.jpeg"] options:SDWebImageCacheMemoryOnly];
    
    [self calculateContentSizeForScrollView];
    [self iminButtonConfig];
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

    
    //
    //
    // Note height
    //
    
    CGSize noteSize = [self.noteLabel.text sizeWithFont:[UIFont systemFontOfSize:14.f] forWidth:self.noteLabel.bounds.size.width lineBreakMode:UILineBreakModeCharacterWrap];
    self.noteLabel.frame = CGRectMake(self.noteLabel.frame.origin.x, self.noteLabel.frame.origin.y, self.noteLabel.frame.size.width, noteSize.height);
    [self.noteLabel sizeToFit];
    CGRect rect = self.noteLabel.frame;
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
    // Set new origin table
    //
    [self.tableView setFrame:CGRectMake(tvFrame.origin.x, TABLE_VIEW_ORIGIN_X + rect.size.height, tvFrame.size.width, ROW_HEIGHT * numberOfComments)];
    
    
    //
    // Scroll to bottom
    //
    self.scrollView.contentSize = CGSizeMake(contentFrame.size.width, contentFrame.size.height);
}

- (void)setReport:(ODMReport *)report
{
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
                
            }
            [self reloadData];
            
            CGRect scrollRect = CGRectMake(0, self.scrollView.contentSize.height + self.commentFormView.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            [self.scrollView scrollRectToVisible:scrollRect animated:YES];
            
            ODMLog(@"Scroll to last %@", NSStringFromCGRect(scrollRect));
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

- (void)cooldownSendImin:(NSTimer *)timer
{
    if (--cooldownSendImin == 0) {
        [timer invalidate];
        [self.iminButton setEnabled:YES];
        [self.iminImage setUserInteractionEnabled:YES];
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


- (IBAction)imin:(id)sender
{
    if ([self isImin]) {
        [[ODMDataManager sharedInstance] deleteIminAtReport:self.report];
    } else {
        [[ODMDataManager sharedInstance] postIminAtReport:self.report];
    }
    
    [self.iminButton setEnabled:NO];
    [self.iminImage setUserInteractionEnabled:NO];
    cooldownSendImin = 3;
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(cooldownSendImin:) userInfo:nil repeats:YES];
    [self updateComment:nil];
}

- (void)iminButtonConfig
{
    if(![self isImin]) {
        [self.iminButton setTitle:@"Imin" forState:UIControlStateNormal];
    } else {
        [self.iminButton setTitle:@"Imout" forState:UIControlStateNormal];
        if ([self isCommentExisted]) {
            [self.iminButton setEnabled:NO];
        }
    }
}

- (BOOL)isImin
{
    for (ODMImin *imin in self.report.imins) {
        if ([imin.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCommentExisted
{
    for (ODMComment *comment in self.report.comments) {
        if ([comment.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UIScrollView

- (void)showCommentForm:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat statusBarHeight = 10;
    
    self.backView.alpha = 0;
    self.backView.hidden = NO;
    [UIView animateWithDuration:animationDuration animations:^{
        self.backView.alpha = 0.0015;
        
        CGRect newFrame = self.commentFormView.frame;
        NSLog(@"keyboard size : %f", keyboardSize.height);
        NSLog(@"all : %f", self.view.frame.size.height);
        NSLog(@"comment view  : %f", self.parentViewController.view.frame.size.height);
        
        newFrame.origin.y = self.parentViewController.view.frame.size.height - statusBarHeight - self.commentFormView.frame.size.height - keyboardSize.height;
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
        self.backView.alpha = 0;
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height;
        self.commentFormView.frame = newFrame;
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.scrollView setContentInset:edgeInsets];
    } completion:^(BOOL finished){
        self.backView.hidden = YES;
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
