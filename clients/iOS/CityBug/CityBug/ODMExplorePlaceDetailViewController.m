

#import "ODMExplorePlaceDetailViewController.h"

#import "ODMDescriptionFormViewController.h"
#import "ODMReportDetailViewController.h"
#import "ODMDescriptionViewController.h"

#import "UIImageView+WebCache.h"
#import "ODMActivityFeedViewCell.h"
#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMComment.h"

#import "MapViewAnnotation.h"

static NSString *gotoViewSegue = @"gotoViewSegue";

@interface ODMExplorePlaceDetailViewController ()
{
    NSArray *datasource;
    UIBarButtonItem *signOutButton;
    
    BOOL isAuthenOld;
    __weak ODMDescriptionFormViewController *_formViewController;
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
    
    // Load data
    datasource = [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
    if (!datasource) datasource = [NSArray new];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReports:)
                                                 name:ODMDataManagerNotificationPlaceReportsLoadingFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePage:)
                                                 name:ODMDataManagerNotificationAuthenDidFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSubscribeStatus:)
                                                 name:ODMDataManagerNotificationPlaceSubscribeDidFinish
                                               object:nil];
    
    CLLocationCoordinate2D location;
	location.latitude = [self.place.latitude doubleValue];
	location.longitude = [self.place.longitude doubleValue];
    
	// Add the annotation to our map view
	MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:self.place.title andCoordinate:location];
	[self.map addAnnotation:newAnnotation];

}

- (void)viewDidUnload
{
    titleLabel = nil;
    [self setMap:nil];
    [self setSubscribeButton:nil];
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
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
    
    region.center = [mp coordinate];
}

- (void)updateSubscribeStatus:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscribe Complete!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    if (self.subscribeButton.enabled == YES) {
        self.subscribeButton.enabled = NO;
    }
}

- (void)updatePage:(NSNotification *)notification
{    
    [[ODMDataManager sharedInstance] reportsWithPlace:self.place];
    [self.tableView reloadData];
    
    [self.actView setHidden:NO];
    
    self.subscribeButton.enabled = !self.place.isSubscribed;
    
    if([[ODMDataManager sharedInstance] isAuthenticated] == NO) {
        self.subscribeButton.enabled = NO;
    }
}

- (void)updateReports:(NSNotification *)notification
{
    [self.actView setHidden:YES];
    
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

@end
