//
//  ODMMyViewController.m
//  CityBug
//
//  Created by Pirapa on 10/3/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMMyViewController.h"

#import "ODMDescriptionFormViewController.h"
#import "ODMReportDetailViewController.h"
#import "ODMDescriptionViewController.h"
#import "ODMUserListTableViewController.h"

#import "UIImageView+WebCache.h"
#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMComment.h"

static NSString *goToUserListSegue = @"goToUserListSegue";
static NSString *gotoViewSegue = @"gotoViewSegue";
static NSString *presentSignInModal = @"presentSignInModal";

@interface ODMMyViewController ()
{
    NSArray *datasource;
    UIBarButtonItem *signOutButton;
    ODMReport *iminUserListReport;
    BOOL isAuthenOld;
    __weak ODMDescriptionFormViewController *_formViewController;
}
@end

@implementation ODMMyViewController
@synthesize userNameLabel;
@synthesize emailLabel;
@synthesize mySubcribeButton;
@synthesize myReportTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:TAB_PROFILE_TITLE];
    
    // Load data
    datasource = [[ODMDataManager sharedInstance] myReports];
    if (!datasource) datasource = [NSArray new];
    [self.myReportTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReports:) name:ODMDataManagerNotificationMyReportsLoadingFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyReport:) name:ODMDataManagerNotificationIminAddDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyReport:) name:ODMDataManagerNotificationIminDeleteDidFinish object:nil];
    signOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOutButtonTapped)];
    
    [self updatePage:nil];

}

- (void)viewDidUnload
{
    [self setUserNameLabel:nil];
    [self setEmailLabel:nil];
    [self setMySubcribeButton:nil];
    [self setMyReportTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self isSignIn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updatePage:(NSNotification *)notification
{
        
    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
    userNameLabel.text = [[dataManager currentUser] username];
    emailLabel.text = [[dataManager currentUser] email];
    [dataManager myReports];
    
//    BOOL isAuthen = [[ODMDataManager sharedInstance] isAuthenticated];
//
//    if (isAuthen == NO && isAuthen != isAuthenOld) {
//        [self performSegueWithIdentifier:@"presentSignInPush" sender:self];
//        [[self navigationItem] setRightBarButtonItem:nil animated:NO];
//        [[self navigationItem] setLeftBarButtonItem:nil animated:NO];
//
//    } else {
//        [[self navigationItem] setRightBarButtonItem:signOutButton animated:NO];
//    }
    [self.myReportTableView reloadData];
//    isAuthenOld = isAuthen;
    
    [self.actView setHidden:NO];
    
    [self isSignIn];
    
}

- (void)updateMyReport:(NSNotification *)notification
{
    ODMReport *report = [[notification userInfo] objectForKey:@"report"];
    
    int index = -1;
    for (int i = 0; i < datasource.count; i++) {
        ODMReport *datasourceReport = [datasource objectAtIndex:i];
        if ([datasourceReport.uid isEqualToString:report.uid]) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:datasource];
        [mutableArray replaceObjectAtIndex:index withObject:report];
        datasource = [NSArray arrayWithArray:mutableArray];
        [self.myReportTableView reloadData];
    }
    
    [[ODMDataManager sharedInstance] myReports];
}

- (void)updateReports:(NSNotification *)notification
{
    [self.actView setHidden:YES];
    
    NSUInteger oldItemsCount = [datasource count];
    
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        datasource = [NSArray arrayWithArray:[notification object]];
        
        
        int diff = abs([datasource count] - oldItemsCount);
        // [NSString stringWithFormat:NSLocalizedString(@"There has no", @"There has no"), NSLocalizedString(@"new reports", @"new reports")]
        NSString *message = diff == 1 ?
        [NSString stringWithFormat:NSLocalizedString(@"There has a new report", @"There has a new report")]
        : [NSString stringWithFormat:NSLocalizedString(@"There have new %i reports", @"There have %i reports"),diff];
        
        ODMLog(@"%@ [%i]",message ,[datasource count]);
    }
    
    [self.myReportTableView reloadData];
    if ([datasource count] == 0) {
        [self.noResultView setHidden:NO];
        [self.myReportTableView setBounces:NO];
    } else {
        [self.noResultView setHidden:YES];
        [self.myReportTableView setBounces:YES];
    }
}

- (BOOL)isSignIn
{
    [self.notLoginView setHidden:YES];
    if ([[ODMDataManager sharedInstance] isAuthenticated] == NO) {
        [self.actView setHidden:YES];
        [self.notLoginView setHidden:NO];
        
        NSLog(@"present signin");
        [self performSegueWithIdentifier:presentSignInModal sender:self];
        
        [[self navigationItem] setRightBarButtonItem:nil];
        return NO;
    } else {
        [[self navigationItem] setRightBarButtonItem:signOutButton];
    }
    return YES;
}

- (void)signOutButtonTapped
{
    [[ODMDataManager sharedInstance] signOut];
    [self updatePage:nil];
    
//    [self changeTabBarToFirstTabBar];
}

- (IBAction)goToPost:(id)sender
{
    [self changeTabBarToFirstTabBar];
}

- (void)changeTabBarToFirstTabBar
{
    UITabBarController *tc = (UITabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tc setSelectedIndex:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportCellIdentifier";
    ODMActivityFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    if (cell && datasource.count > indexPath.row) {
        
        ODMReport *report = [datasource objectAtIndex:indexPath.row];
        cell.report = report;
        
        // Image Cache
        NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, cell.report.thumbnailImage]];
        [cell.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    }
    return cell;
}
#pragma mark - segue

- (void)setFormViewController:(ODMDescriptionFormViewController *)vc
{
    _formViewController = vc;
}

- (ODMDescriptionFormViewController *)formViewController
{
    return _formViewController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:gotoViewSegue]) {
        
        ODMReportDetailViewController *detailViewController = (ODMReportDetailViewController *) segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.myReportTableView indexPathForCell:(UITableViewCell *)sender];
        
        if (datasource.count > selectedIndexPath.row) {
            ODMReport *aReport = [datasource objectAtIndex:selectedIndexPath.row];
            detailViewController.report = aReport;
        }
    } else if ([segue.identifier isEqualToString:goToUserListSegue]) {
        
        ODMUserListTableViewController *userListTableViewController = (ODMUserListTableViewController *) segue.destinationViewController;
        userListTableViewController.report = iminUserListReport;
    }
}

#pragma mark - ODMActivityFeedViewCell delegate

- (void)didClickIminLabelWithReport:(ODMReport *)report
{
    iminUserListReport = report;
    [self performSegueWithIdentifier:goToUserListSegue sender:self];
}

@end
