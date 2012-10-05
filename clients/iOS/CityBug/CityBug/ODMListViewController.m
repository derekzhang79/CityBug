//
//  ODMListViewController.m
//  CityBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMListViewController.h"
#import "ODMDescriptionFormViewController.h"
#import "ODMReportDetailViewController.h"
#import "ODMDescriptionViewController.h"

#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImageView+WebCache.h"
#import "ODMActivityFeedViewCell.h"
#import "ODMDataManager.h"
#import "ODMReport.h"
#import "ODMComment.h"

#import "ODMSignInViewController.h"

#define kSceenSize self.parentViewController.view.frame.size
#define CAMERA_SCALAR 1.0

static NSString *gotoFormSegue = @"presentFormSegue";
static NSString *gotoViewSegue = @"gotoViewSegue";
static NSString *presentSignInModal = @"presentSignInModal";

@implementation ODMListViewController {
    CLLocationManager *locationManager;
    UIImage *imageToSave;
    UIImagePickerController *picker;
    NSArray *datasource;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock;
    ALAssetsLibraryAccessFailureBlock failureblock;
    ALAssetsLibrary *assetsLib;
    CLLocation *location;
    
    NSUInteger cooldownReloadButton;
    NSInteger updatingCount;
    
    __weak ODMDescriptionFormViewController *_formViewController;
}

@synthesize location;


#pragma mark - View's Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:NOW_TABBAR];
    [self updatePage:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    updatingCount = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    updatingCount = DATA_UPDATING_INTERVAL_IN_SECOND;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"City Bug"];
    
    // Load data
    datasource = [[ODMDataManager sharedInstance] reports];
    if (!datasource) datasource = [NSArray new];
    [self.tableView reloadData];
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
    self.location = locationManager.location;

    resultblock = ^(ALAsset *myasset) {
        CLLocation *locationAsset = [myasset valueForProperty:ALAssetPropertyLocation];
        self.location = locationAsset;
        _formViewController.pictureLocation = locationAsset;
    };
    failureblock = ^(NSError *myerror) {
        NSLog(@"error while get Location from picture : %d - message: %s", errno, strerror(errno));
        self.location = nil;
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReports:) name:ODMDataManagerNotificationReportsLoadingFinish object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
}

- (void)viewDidUnload
{
    [locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updatePage:(NSNotification *)notification
{
    [[ODMDataManager sharedInstance] reports];
    
    BOOL isAuthen = [[ODMDataManager sharedInstance] isAuthenticated];
    
    if (isAuthen) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addButtonTapped:)];
        
        [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:cameraButton, nil] animated:NO];
    } else {
        [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithTitle:@"Sign in" style:UIBarButtonItemStyleBordered target:self action:@selector(signInButtonTapped:)]]];
    }
    
}

- (void)updateReports:(NSNotification *)notification
{
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

#pragma mark - REPORT

- (void)cooldownButtonAction:(NSTimer *)timer
{
    cooldownReloadButton -= 1;
    
    if (cooldownReloadButton == 0) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [timer invalidate];
    }
}

- (void)signOutButtonTapped
{
    [[ODMDataManager sharedInstance] signOut];
}

- (IBAction)signInButtonTapped:(id)sender
{
    NSLog(@"present signin");
    [self performSegueWithIdentifier:presentSignInModal sender:self];
}

- (IBAction)addButtonTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Source"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Camera", @"Existing Photo", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [[ODMDataManager sharedInstance] reports];
    
    ODMLog(@"%@",NSLocalizedString(@"Fetching new reports", @"Fetching new reports"));
    
    cooldownReloadButton = 3;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cooldownButtonAction:) userInfo:nil repeats:YES];
}


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

    if (!assetsLib) {
        assetsLib = [[ALAssetsLibrary alloc] init];
    }
    
    if (aPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.location = locationManager.location;
        
        // get Metadata's image for add more attribute (location attribute).
        NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
        [metadata setValue:self.location forKey:ALAssetPropertyLocation];
        
        // save image and metadata to the Photos Album.
        [assetsLib writeImageToSavedPhotosAlbum:imageToSave.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"image saved");
        }];
 
    } else if (aPicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSURL *pictureURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        //  invokes a given block passing as a parameter an asset identified by a specified file URL.
        [assetsLib assetForURL:pictureURL resultBlock:resultblock failureBlock:failureblock];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    [self performSegueWithIdentifier:gotoFormSegue sender:self];
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
    if ([segue.identifier isEqualToString:gotoFormSegue]) {
        ODMDescriptionFormViewController *formViewController = (ODMDescriptionFormViewController *) segue.destinationViewController;
        [self setFormViewController:formViewController];
        formViewController.bugImage = imageToSave;
        formViewController.pictureLocation = self.location;
    }
    else if ([segue.identifier isEqualToString:gotoViewSegue]) {
        
        ODMReportDetailViewController *detailViewController = (ODMReportDetailViewController *) segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];

        if (datasource.count > selectedIndexPath.row) {
            ODMReport *aReport = [datasource objectAtIndex:selectedIndexPath.row];
            detailViewController.report = aReport;
        }
    }
}

@end
