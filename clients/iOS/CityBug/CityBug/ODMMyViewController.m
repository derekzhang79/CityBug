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

#import "UIImageView+WebCache.h"
#import "ODMActivityFeedViewCell.h"
#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMComment.h"

@interface ODMMyViewController ()
{
    NSArray *datasource;
    UIBarButtonItem *signOutButton;
    
    BOOL isAuthenOld;
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
    [self setTitle:@"Profile"];
    
    // Load data
    datasource = [[ODMDataManager sharedInstance] myReports];
    if (!datasource) datasource = [NSArray new];
    [self.myReportTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReports:) name:ODMDataManagerNotificationMyReportsLoadingFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
    
    signOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOutButtonTapped)];

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
    
    [self updatePage:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updatePage:(NSNotification *)notification
{
    [[ODMDataManager sharedInstance] myReports];
    
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
}

- (void)updateReports:(NSNotification *)notification
{
    NSUInteger oldItemsCount = [datasource count];
    
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        datasource = [NSArray arrayWithArray:[notification object]];
        
        [self.myReportTableView reloadData];
        
        int diff = abs([datasource count] - oldItemsCount);
        // [NSString stringWithFormat:NSLocalizedString(@"There has no", @"There has no"), NSLocalizedString(@"new reports", @"new reports")]
        NSString *message = diff == 1 ?
        [NSString stringWithFormat:NSLocalizedString(@"There has a new report", @"There has a new report")]
        : [NSString stringWithFormat:NSLocalizedString(@"There have new %i reports", @"There have %i reports"),diff];
        
        ODMLog(@"%@ [%i]",message ,[datasource count]);
    }
}

- (void)signOutButtonTapped
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSError *error = nil;
    // use http basic send, nothing
    [[ODMDataManager sharedInstance] signInCityBugUserWithError:&error];
    
    [self updatePage:nil];
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
    
    if (cell && datasource.count > indexPath.row) {
        
        ODMReport *report = [datasource objectAtIndex:indexPath.row];
        cell.report = report;
        
        // Image Cache
        NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, cell.report.thumbnailImage]];
        [cell.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    }
    return cell;
}

@end
