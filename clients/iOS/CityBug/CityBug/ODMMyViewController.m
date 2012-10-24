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
#import "ODMListViewController.h"

#import "UIImageView+WebCache.h"
#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMComment.h"


#define kSceenSize self.parentViewController.view.frame.size
#define CAMERA_SCALAR 1.0

static NSString *goToUserListSegue = @"goToUserListSegue";
static NSString *gotoViewSegue = @"gotoViewSegue";
static NSString *presentSignInModal = @"presentSignInModal";
static NSString *gotoIminFeedList = @"gotoIminFeedList";

@interface ODMMyViewController ()
{
    NSArray *datasource;
    UIBarButtonItem *signOutButton;
    ODMReport *iminUserListReport;
    BOOL isAuthenOld;
    __weak ODMDescriptionFormViewController *_formViewController;
    NSInteger cooldownReloadButton;
    UIImage *imageToSave;
    UIImagePickerController *picker;
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

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:TAB_PROFILE_TITLE];
    
    self.nibLoader = [UINib nibWithNibName:@"ODMActivityFeedViewCell" bundle:nil];
    [self.myReportTableView registerNib:self.nibLoader forCellReuseIdentifier:@"ReportCellIdentifier"];
    
    // Load data
    datasource = [[ODMDataManager sharedInstance] myReports];
    if (!datasource) datasource = [NSArray new];
    [self.myReportTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReports:) name:ODMDataManagerNotificationMyReportsLoadingFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyReport:) name:ODMDataManagerNotificationIminAddDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyReport:) name:ODMDataManagerNotificationIminDeleteDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportAndAlertIminFail:) name:ODMDataManagerNotificationIminDidFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadReport:) name:ODMDataManagerNotificationCommentLoadingFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage:) name:ODMDataManagerNotificationChangeProfileDidFinish object:nil];
    
    signOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOutButtonTapped)];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailImageAction)];
    [self.thumbnailImageView addGestureRecognizer:tapGesture];
    
    [self updatePage:nil];

}

- (void)viewDidUnload
{
    [self setUserNameLabel:nil];
    [self setEmailLabel:nil];
    [self setMySubcribeButton:nil];
    [self setMyReportTableView:nil];
    [self setThumbnailImageView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myReportTableView reloadData];
    [self isSignIn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - notification

- (void)updatePage:(NSNotification *)notification
{
    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
    userNameLabel.text = [[dataManager currentUser] username];
    emailLabel.text = [[dataManager currentUser] email];
    //memberSinceDateLabel.text = [[dataManager currentUser] createdDate];

    // set profile image
    NSString *thumbnailImage = [[dataManager currentUser] thumbnailImage];
    if (thumbnailImage != nil && [thumbnailImage isEqualToString:@""] == NO) {
        NSURL *thumbnailURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, thumbnailImage]];
        NSData *imageData = [NSData dataWithContentsOfURL:thumbnailURL];
        self.thumbnailImageView.image = [UIImage imageWithData:imageData];
    } else {
        self.thumbnailImageView.image = [UIImage imageNamed:@"1.jpeg"];
    }
    [dataManager myReports];
    
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
    
    if ([datasource count] == 0) {
        [self.noResultView setHidden:NO];
        [self.myReportTableView setBounces:NO];
    } else {
        [self.noResultView setHidden:YES];
        [self.myReportTableView setBounces:YES];
    }
    [self.myReportTableView reloadData];
}

- (void)updateReportAndAlertIminFail:(NSNotification *)notification
{
    [[ODMDataManager sharedInstance] myReports];
}

- (void)loadReport:(NSNotification *)notification
{
    [[ODMDataManager sharedInstance] myReports];
}

#pragma mark - action

- (void)thumbnailImageAction
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Image"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Existing Photo", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.tabBarController.view];
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [[ODMDataManager sharedInstance] myReports];
    
    ODMLog(@"%@",NSLocalizedString(@"Fetching new reports", @"Fetching new reports"));
    
    cooldownReloadButton = 3;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cooldownButtonAction:) userInfo:nil repeats:YES];
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

#pragma mark - cooldown

- (void)cooldownButtonAction:(NSTimer *)timer
{
    cooldownReloadButton -= 1;
    
    if (cooldownReloadButton == 0) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [timer invalidate];
    }
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
    if (cell == nil) {
        cell = [[self.nibLoader instantiateWithOwner:self options:nil] objectAtIndex:0];
    }
    
    cell.delegate = self;
    if (cell && datasource.count > indexPath.row) {
        
        ODMReport *report = [datasource objectAtIndex:indexPath.row];
        cell.report = report;
        
        // Image Cache
        NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, cell.report.thumbnailImage]];
        [cell.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
        if (cell.report.user.thumbnailImage != nil) {
            NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, cell.report.user.thumbnailImage]];
            [cell.avatarImageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"1.jpeg"] options:SDWebImageCacheMemoryOnly];
        } else {
            [cell.avatarImageView setImage:[UIImage imageNamed:@"1.jpeg"]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:gotoViewSegue sender:[self.myReportTableView cellForRowAtIndexPath:indexPath]];
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
        
    } else if ([segue.identifier isEqualToString:gotoIminFeedList]) {
        ODMListViewController *listView = (ODMListViewController *)segue.destinationViewController;
        listView.reportsType = TYPE_REPORTS_IMIN;
    }
}

#pragma mark - ODMActivityFeedViewCell delegate

- (void)didClickIminLabelWithReport:(ODMReport *)report
{
    iminUserListReport = report;
    [self performSegueWithIdentifier:goToUserListSegue sender:self];
}

#pragma mark - Image Picker


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!picker) {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
    }
    
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.wantsFullScreenLayout = YES;
        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);
        
    } else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    } else {
        return;
    }
    
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    self.thumbnailImageView.image = imageToSave;
    [[ODMDataManager sharedInstance] editUserThumbnailWithImage:imageToSave];
    [self dismissModalViewControllerAnimated:YES];
}


@end
