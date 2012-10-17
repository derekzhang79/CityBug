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
#import "ODMUserListTableViewController.h"

#define ROW_HEIGHT 44
#define PEOPLE_ARE_IN @" people are in!"
static NSString *goToUserListSegue = @"goToUserListSegue";

@implementation ODMReportDetailViewController {
    NSUInteger numberOfComments;
    NSUInteger cooldownSendButton;
    NSUInteger cooldownSendImin;
}

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resignFirstResponder];
    
    self.title = NSLocalizedString(@"Report", @"Report");
    self.commentTextField.placeholder = NSLocalizedString(@"Enter comment here", @"Enter comment here");
    // Show or hide keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentForm:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCommentForm:) name:UIKeyboardWillHideNotification object:nil];

    //Datamanager notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingComments:) name:ODMDataManagerNotificationReportsLoadingFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComment:) name:ODMDataManagerNotificationCommentLoadingFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCommentView:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImin:) name:ODMDataManagerNotificationIminAddDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImin:) name:ODMDataManagerNotificationIminDeleteDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideIminButton:) name:ODMDataManagerNotificationIminDidLoading object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportAndAlertIminFail:) name:ODMDataManagerNotificationIminDidFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:ODMDataManagerNotificationChangeProfileDidFinish object:nil];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.backView addGestureRecognizer:tapGesture];

    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iminLabelAction)];
    [self.iminLabel addGestureRecognizer:tapGesture2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateCommentView:nil];

    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.tableView scrollsToTop];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

#pragma mark - Action

- (IBAction)imin:(id)sender
{
    if ([self isImin]) {
        [[ODMDataManager sharedInstance] deleteIminAtReport:self.report];
    } else {
        [[ODMDataManager sharedInstance] postIminAtReport:self.report];
    }
    
    [self.iminButton setEnabled:NO];
    [self.iminImage setUserInteractionEnabled:NO];
}

- (void)iminLabelAction
{
    [self performSegueWithIdentifier:goToUserListSegue sender:self];
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

#pragma mark - Datasource

- (void)reloadData
{
    if (!self.report) return;
    
    [self authenticatedConfig];
    
    self.titleLabel.text = [self.report title];
    self.userLabel.text = [self.report.user username];
    self.createdAtLabel.text = [self.report.createdAt stringWithHumanizedTimeDifference];
    self.iminLabel.text = [self.report iminString];
    self.locationLabel.text = [self.report.place title];
    self.noteLabel.text = [NSString stringWithFormat:@"%@", [self.report note] == @"" ? @" " : [self.report note]];
    
    // Report Image
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, [self.report fullImage]]];
    [self.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    
    // Avatar Image
    if (self.report.user.thumbnailImage != nil) {
        NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, self.report.user.thumbnailImage]];
        [self.avatarImageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"1.jpeg"] options:SDWebImageCacheMemoryOnly];
    } else {
        [self.avatarImageView setImage:[UIImage imageNamed:@"1.jpeg"]];
    }
    [self calculateTableViewSize];
    [self iminButtonConfig];

    [self.tableView reloadData];
}

- (void)calculateTableViewSize
{
    if (!self.report) return;
    
    // Calculate comment number
    numberOfComments = self.report.comments.count;
    
    // Calculate Note label height
    CGSize noteSize = [self.noteLabel.text sizeWithFont:[UIFont systemFontOfSize:14.f] forWidth:self.noteLabel.bounds.size.width lineBreakMode:UILineBreakModeCharacterWrap];
    self.noteLabel.frame = CGRectMake(self.noteLabel.frame.origin.x, self.noteLabel.frame.origin.y, self.noteLabel.frame.size.width, noteSize.height);
    [self.noteLabel sizeToFit];
    
    CGRect rect = self.noteLabel.frame;
    CGRect infoFrame = self.infoView.frame;
    
    // Value from Storyboard
    CGFloat defaultNoteLabelHeight = 22;
    CGFloat defaultInfoViewHeight = 350;
    
    // Set frame to info view (tableview header)
    if (abs(self.noteLabel.frame.size.height - defaultNoteLabelHeight) > 0) {
        infoFrame.size.height = defaultInfoViewHeight + rect.size.height;
    } else {
        infoFrame.size.height = defaultInfoViewHeight;
    }
    [self.infoView setFrame:infoFrame];

}


- (void)setReport:(ODMReport *)report
{
    if (!report) return;
    _report = report;
    
    [self reloadData];
}

#pragma mark - Notifications

// get new comment
- (void)incomingComments:(NSNotification *)notification
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
            
            [self tableViewScrollToLast];
        
        }
    }
    [self.iminButton setEnabled:YES];
    [self iminButtonConfig];
}

- (void)tableViewScrollToLast
{
    int numberOfDatasource = [self.tableView numberOfRowsInSection:0];
    if (numberOfDatasource > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfDatasource - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } else {
        [self.tableView scrollRectToVisible:self.noteLabel.frame animated:YES];
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

- (void)updateCommentView:(NSNotificationCenter *)noti
{
    [self authenticatedConfig];
}

- (void)updateImin:(NSNotification *)notification
{
    ODMReport *report = [[notification userInfo] objectForKey:@"report"];
    [self setReport:report];
    [[ODMDataManager sharedInstance] reports];
}

- (void)updateReportAndAlertIminFail:(NSNotification *)noti
{
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
    else if ([segue.identifier isEqualToString:goToUserListSegue]) {
        ODMUserListTableViewController *detailViewController = (ODMUserListTableViewController *)segue.destinationViewController;
        detailViewController.report = self.report;
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

#pragma mark - imin config

- (void)iminButtonConfig
{
    if (![[ODMDataManager sharedInstance] isAuthenticated]) {
        [self.iminButton setEnabled:NO];
        return;
    }
    [self.iminButton setEnabled:YES];
    if(![self isImin]) {
        [self.iminButton setTitle:@"Imin" forState:UIControlStateNormal];
    } else {
        [self.iminButton setTitle:@"Imout" forState:UIControlStateNormal];
        if ([self isCommentExisted]) {
            [self.iminButton setEnabled:NO];
        }
    }
}

- (void)hideIminButton:(NSNotification *)notification
{
    ODMReport *report = [notification object];
    if ([self.report.uid isEqualToString:[report uid]]) {
        [self.iminButton setEnabled:NO];
    }
}

- (BOOL)isImin
{
    for (ODMImin *imin in self.report.imins) {
        if ([imin.user.username isEqualToString:[[[ODMDataManager sharedInstance] currentUser] username]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCommentExisted
{
    for (ODMComment *comment in self.report.comments) {
        if ([comment.user.username isEqualToString:[[[ODMDataManager sharedInstance] currentUser] username]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - authenticatedConfig

- (void)authenticatedConfig
{
    BOOL isAuthen = [[ODMDataManager sharedInstance] isAuthenticated];
    
    if (isAuthen) {
        // Show comment view
        self.commentFormView.hidden = NO;
        self.iminImage.userInteractionEnabled = YES;
        [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 323)];
        
    } else {
        // Hide comment view
        self.commentFormView.hidden = YES;
        [self.iminButton setEnabled:NO];
        self.iminImage.userInteractionEnabled = NO;
        [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

#pragma mark - cooldown


- (void)cooldownSendAction:(NSTimer *)timer;
{
    if (--cooldownSendButton == 0) {
        [timer invalidate];
        [self.sendButton setEnabled:YES];
    }
}

#pragma mark - UIScrollView

// When show keyboard
- (void)showCommentForm:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat statusBarHeight = 15;
    
    self.backView.alpha = 0;
    self.backView.hidden = NO;
    [UIView animateWithDuration:animationDuration animations:^{
        self.backView.alpha = 1;
        
        CGRect newFrame = self.commentFormView.frame;
        NSLog(@"keyboard size : %f", keyboardSize.height);
        NSLog(@"all : %f", self.view.frame.size.height);
        NSLog(@"comment view  : %f", self.parentViewController.view.frame.size.height);

        newFrame.origin.y = self.parentViewController.view.frame.size.height - statusBarHeight - self.commentFormView.frame.size.height - keyboardSize.height;
        self.commentFormView.frame = newFrame;
        
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        [self.tableView setContentInset:edgeInsets];
    }];
    
    [self tableViewScrollToLast];
    
}

// When hide keyboard
- (void)hideCommentForm:(NSNotification *)notification
{
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.backView.alpha = 0;
        
        CGRect newFrame = self.commentFormView.frame;
        newFrame.origin.y = self.view.frame.size.height - self.commentFormView.frame.size.height;
        self.commentFormView.frame = newFrame;
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.tableView setContentInset:edgeInsets];
    } completion:^(BOOL finished){
        self.backView.hidden = YES;
    }];
    
//    [self tableViewScrollToLast];
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
    // Calculate comment label size
    NSString *note = [(ODMComment *)[self.report.comments objectAtIndex:indexPath.row] text];
    UIFont *font = [UIFont systemFontOfSize:14.f];
    CGSize constraintSize = CGSizeMake(300, MAXFLOAT);
    CGSize bounds = [note sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeCharacterWrap];
    int offset = 30;
    CGFloat height = bounds.height + offset;
    
    return height;
}


@end
