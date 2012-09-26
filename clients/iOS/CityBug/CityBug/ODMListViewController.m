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

#define kSceenSize self.parentViewController.view.frame.size
#define CAMERA_SCALAR 1.32

static NSString *gotoFormSegue = @"presentFormSegue";
static NSString *gotoViewSegue = @"gotoViewSegue";

@interface ODMListViewController () {
    CLLocationManager *locationManager;
}

@end

@implementation ODMListViewController {
    UIImage *imageToSave;
    UIImagePickerController *picker;
    NSArray *datasource;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock;
    ALAssetsLibraryAccessFailureBlock failureblock;
    ALAssetsLibrary *assetsLib;
    CLLocation *location;
    
    NSUInteger cooldownReloadButton;
    NSTimer *cooldownTimer;
    
    NSMutableArray *notificationCacheArray;
}

@synthesize location;


#pragma mark - View's Life Cycle

- (void)pushMessageToStatusBar:(NSString *)text
{
    FDStatusBarNotifierView *notifierView = [[FDStatusBarNotifierView alloc] initWithMessage:text delegate:self];
    notifierView.userInteractionEnabled = YES;
    notifierView.timeOnScreen = 2.0;
    
    [notifierView showInWindow:self.view.window];
    
    [notificationCacheArray addObject:notifierView];
}

- (void)pushMessageToStatusBar:(NSString *)text afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(pushMessageToStatusBar:) withObject:text afterDelay:delay];
}

- (void)didHideNotifierView:(FDStatusBarNotifierView *)notifierView
{
    [notificationCacheArray removeObject:notifierView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[ODMDataManager sharedInstance] reports];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (FDStatusBarNotifierView *view in notificationCacheArray)
        [view hide];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"CityBug"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
    self.location = locationManager.location;

    resultblock = ^(ALAsset *myasset) {
        CLLocation *locationAsset = [myasset valueForProperty:ALAssetPropertyLocation];
        self.location = locationAsset;
    };
    failureblock = ^(NSError *myerror) {
        NSLog(@"error while get Location from picture : %d - message: %s", errno, strerror(errno));
        self.location = nil;
    };
    
    datasource = [[ODMDataManager sharedInstance] reports];
    
    if (!datasource) {
        datasource = [NSArray new];
    }
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReports:) name:ODMDataManagerNotificationReportsLoadingFinish object:nil];
    
    // Cache for notification bar on top
    // use for switch to other pages
    notificationCacheArray = [NSMutableArray new];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateReports:(NSNotification *)notification
{
    NSUInteger oldItemsCount = [datasource count];
    datasource = (NSArray *)[notification object];
    
    [self.tableView reloadData];
    
    int diff = abs([datasource count] - oldItemsCount);
    NSString *message = diff == 0 ?
                [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"There has no", @"There has no"), NSLocalizedString(@"new reports", @"new reports")]
                : [NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"There has", @"There has"), diff, NSLocalizedString(@"new reports", @"new reports")];

    
    [self pushMessageToStatusBar:message afterDelay:2.0];
    
    ODMLog(@"update reports [%i]", [datasource count]);
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
    ODMReport *report = [datasource objectAtIndex:indexPath.row];
    
    cell.report = report;
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, cell.report.thumbnailImage]];
    
    [cell.reportImageView setImageWithURL:reportURL placeholderImage:[UIImage imageNamed:@"bugs.jpeg"] options:SDWebImageCacheMemoryOnly];
    
    return cell;
}

#pragma mark - REPORT

- (void)cooldownButton
{
    cooldownReloadButton -= 1;
    
    if (cooldownReloadButton == 0) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [cooldownTimer invalidate];
    }
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
    
    [self pushMessageToStatusBar:NSLocalizedString(@"Fetching new reports", @"Fetching new reports")];
    
    cooldownReloadButton = 3;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    cooldownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cooldownButton) userInfo:nil repeats:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    picker =  [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.wantsFullScreenLayout = YES;
        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);
        
        [self presentModalViewController:picker animated:YES];
        
    } else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
    }
}


- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];

   
    assetsLib = [[ALAssetsLibrary alloc] init];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:gotoFormSegue]) {
        ODMDescriptionFormViewController *formViewController = (ODMDescriptionFormViewController *) segue.destinationViewController;
        formViewController.bugImage = imageToSave;
        formViewController.location = self.location;
        
    }
    else if ([segue.identifier isEqualToString:gotoViewSegue]) {
        
        ODMReportDetailViewController *detailViewController = (ODMReportDetailViewController *) segue.destinationViewController;

        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];

        detailViewController.report = [datasource objectAtIndex:selectedIndexPath.row];
    }
}

@end
