

#import "ODMExplorePlaceDetailViewController.h"

#import "ODMDescriptionFormViewController.h"
#import "ODMReportDetailViewController.h"
#import "ODMDescriptionViewController.h"
#import "ODMExploreFormViewController.h"

#import "UIImageView+WebCache.h"
#import "ODMActivityFeedViewCell.h"
#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMComment.h"

#import "MapViewAnnotation.h"

static NSString *gotoViewSegue = @"gotoViewSegue";
static NSString *presentSignInModal = @"presentSignInModal";

@interface ODMExplorePlaceDetailViewController ()
{
    NSArray *datasource;
    
    BOOL isAuthenOld;
    __weak ODMDescriptionFormViewController *_formViewController;
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)subscribeComplete:(NSNotification *)notification
{
    self.place.isSubscribed = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscribe Complete!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self updateSubscribeStatus];
}

- (void)unsubscribeComplete:(NSNotification *)notification
{
    self.place.isSubscribed = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsubscribe Complete!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self updateSubscribeStatus];
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

- (void)signInButtonAction
{
    //must refresh subscribe status from explore place list
    [self performSegueWithIdentifier:presentSignInModal sender:self];
}

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

- (IBAction)subscribeButtonAction:(id)sender
{
    [[ODMDataManager sharedInstance] postNewSubscribeToPlace:self.place];
}

- (IBAction)unsubscribeButtonAction:(id)sender
{
//    [[ODMDataManager sharedInstance] unsubscribeToPlace:self.place];
    [[ODMDataManager sharedInstance] postNewSubscribeToPlace:self.place];
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
    }
    
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
