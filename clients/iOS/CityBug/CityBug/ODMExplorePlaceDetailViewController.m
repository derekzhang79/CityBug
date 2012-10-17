

#import "ODMExplorePlaceDetailViewController.h"

#import "ODMDescriptionFormViewController.h"
#import "ODMReportDetailViewController.h"
#import "ODMDescriptionViewController.h"
#import "ODMExploreFormViewController.h"
#import "ODMUserListTableViewController.h"

#import "UIImageView+WebCache.h"
#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMComment.h"

#import "MapViewAnnotation.h"

static NSString *goToUserListSegue = @"goToUserListSegue";
static NSString *gotoViewSegue = @"gotoViewSegue";
static NSString *presentSignInModal = @"presentSignInModal";

@interface ODMExplorePlaceDetailViewController ()
{
    NSArray *datasource;
    NSInteger cooldownReloadButton;
    BOOL isAuthenOld;
    __weak ODMDescriptionFormViewController *_formViewController;
    ODMReport *iminUserListReport;
    UIBarButtonItem *subscribeButton, *unsubscribeButton, *signinButton;
}
@end

@implementation ODMExplorePlaceDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nibLoader = [UINib nibWithNibName:@"ODMActivityFeedViewCell" bundle:nil];
    [self.tableView registerNib:self.nibLoader forCellReuseIdentifier:@"ReportCellIdentifier"];
    
    titleLabel.text = self.place.title;
    self.title = self.place.title;
    
    subscribeButton = [[UIBarButtonItem alloc] initWithTitle:@"Subscribe" style:UIBarButtonItemStyleBordered target:self action:@selector(subscribeButtonAction:)];
    unsubscribeButton = [[UIBarButtonItem alloc] initWithTitle:@"Unsubscribe" style:UIBarButtonItemStyleBordered target:self action:@selector(unsubscribeButtonAction:)];
    signinButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign in" style:UIBarButtonItemStyleBordered target:self action:@selector(signInButtonAction)];
    
    // Load data
    datasource = [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
    if (!datasource) datasource = [NSArray new];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReports:)
                                                 name:ODMDataManagerNotificationPlaceReportsLoadingFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReports:)
                                                 name:ODMDataManagerNotificationPlaceReportsLoadingFail
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(waitingForUpdatePlace)
                                                 name:ODMDataManagerNotificationAuthenDidFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(subscribeComplete:)
                                                 name:ODMDataManagerNotificationPlaceSubscribeDidFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unsubscribeComplete:)
                                                 name:ODMDataManagerNotificationPlaceUnsubscribeDidFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePlaceReport:)
                                                 name:ODMDataManagerNotificationIminAddDidFinish
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePlaceReport:)
                                                 name:ODMDataManagerNotificationIminDeleteDidFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReportAndAlertIminFail:)
                                                 name:ODMDataManagerNotificationIminDidFail
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadReport:)
                                                 name:ODMDataManagerNotificationCommentLoadingFinish
                                               object:nil];
    CLLocationCoordinate2D location;
	location.latitude = [self.place.latitude doubleValue];
	location.longitude = [self.place.longitude doubleValue];
    
	// Add the annotation to our map view
	MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:self.place.title andCoordinate:location];
	[self.map addAnnotation:newAnnotation];
    
    [self.actView setHidden:YES];
}

- (void)viewDidUnload
{
    titleLabel = nil;
    [self setMap:nil];
    [self setRightButton:nil];
    [self updatePage:nil];
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

# pragma mark - action

- (IBAction)refreshButtonTapped:(id)sender
{
    [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
    
    ODMLog(@"%@",NSLocalizedString(@"Fetching new reports", @"Fetching new reports"));
    
    cooldownReloadButton = 3;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cooldownButtonAction:) userInfo:nil repeats:YES];
}

// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
    int radius = 1000;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], radius, radius);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
    
    region.center = [mp coordinate];
}

- (void)updateSubscribeStatus
{
    if (self.place.isSubscribed == YES) {
        [self.navigationItem setRightBarButtonItem:unsubscribeButton];
    } else {
        [self.navigationItem setRightBarButtonItem:subscribeButton];
    }
}

- (void)waitingForUpdatePlace
{
    [self.actView setHidden:NO];
    
    [subscribeButton setEnabled:NO];
    [unsubscribeButton setEnabled:NO];
}

- (void)signInButtonAction
{
    //must refresh subscribe status from explore place list
    [self performSegueWithIdentifier:presentSignInModal sender:self];
}

- (IBAction)subscribeButtonAction:(id)sender
{
    [[ODMDataManager sharedInstance] postNewSubscribeToPlace:self.place];
}

- (IBAction)unsubscribeButtonAction:(id)sender
{
//    [[ODMDataManager sharedInstance] unsubscribeToPlace:self.place];
    [[ODMDataManager sharedInstance] postNewSubscribeToPlace:self.place];
}

#pragma mark - notification

- (void)updateReports:(NSNotification *)notification
{
    //    [self.actView setHidden:YES];
    
    NSUInteger oldItemsCount = [datasource count];
    
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        datasource = [NSArray arrayWithArray:[notification object]];
        
        [self.tableView reloadData];
        
        int diff = abs([datasource count] - oldItemsCount);
        // [NSString stringWithFormat:NSLocalizedString(@"There has no", @"There has no"), NSLocalizedString(@"new reports", @"new reports")]
        NSString *message = diff == 1 ?
        [NSString stringWithFormat:NSLocalizedString(@"There has a new report", @"There has a new report")]
        : [NSString stringWithFormat:NSLocalizedString(@"There have new %i reports", @"There have %i reports"),diff];
        
        ODMLog(@"%@ [%i]",message ,[datasource count]);
    }
    
    if ([datasource count] == 0) {
        [self.noResultView setHidden:NO];
        [self.tableView setBounces:NO];
    } else {
        [self.noResultView setHidden:YES];
        [self.tableView setBounces:YES];
    }
}

- (void)updatePage:(NSNotification *)notification
{
    [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
    [self.tableView reloadData];
    
    //    [self.actView setHidden:NO];
    
    if([[ODMDataManager sharedInstance] isAuthenticated] == NO) {
        //        self.rightButton.enabled = NO;
        [self.navigationItem setRightBarButtonItem:signinButton];
    } else {
        [self updateSubscribeStatus];
    }
}

- (void)updatePlaceReport:(NSNotification *)notification
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
        [self.tableView reloadData];
    }
    [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
}

- (void)updateReportAndAlertIminFail:(NSNotification *)noti
{
    [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
}

- (void)subscribeComplete:(NSNotification *)notification
{
    self.place.isSubscribed = YES;
    [self updateSubscribeStatus];
}

- (void)unsubscribeComplete:(NSNotification *)notification
{
    self.place.isSubscribed = NO;
    [self updateSubscribeStatus];
}

- (void)loadReport:(NSNotification *)notification
{
    [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
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
    [self performSegueWithIdentifier:gotoViewSegue sender:[self.tableView cellForRowAtIndexPath:indexPath]];
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
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        
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

#pragma mark - explore form view controller delegate

- (void)updatePlace:(ODMExploreFormViewController *)delegate withPlace:(ODMPlace *)place
{
    if (place != nil) {
        self.place = place;
        [self updatePage:nil];
    }
    [self.actView setHidden:YES];
    [subscribeButton setEnabled:YES];
    [unsubscribeButton setEnabled:YES];
}

@end
