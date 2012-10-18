//
//  ODMDescriptionFormViewController.m
//  CityBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMDescriptionFormViewController.h"
#import "ODMDataManager.h"

#import "ODMReport.h"

#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define PLACE_HOLDER_NOTE @"Report Note"

@implementation ODMDescriptionFormViewController {
    NSMutableDictionary *entryDict;
    
    CLLocationManager *_locationManager;
    CLLocation *_location;

    ODMPlace *selectedPlace;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.progressView setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:ODMDataManagerNotificationReportUploadingWithPercent object:nil];
    
    self.bugImageView.image = self.bugImage;
    self.noteTextView.placeholder = PLACE_HOLDER_NOTE;
    
    [self startGatheringLocation];
}

- (void)viewDidUnload
{
    [self stopGatheringLocation];
    self.progressView = nil;
    self.progress = nil;
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (IBAction)doneButtonTapped:(id)sender
{
    if ([self createNewReport]) {
        [self updateProgress:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)resignFirstResponder
{
    [self.titleTextField resignFirstResponder];
    [self.noteTextField resignFirstResponder];
    [self.noteTextView resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"categorySegueIdentifier"]) {
        ODMCategoryListViewController *formVC = segue.destinationViewController;
        formVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PlaceFormSequeIdentifier"]) {
        ODMPlaceFormViewController *formVC = segue.destinationViewController;
        formVC.delegate = self;
    }
}

#pragma mark - REPORT

- (void)updateProgress:(NSNotification *)notification
{
    float progressNumber = 0;
    [self.progressView setHidden:NO];
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        progressNumber = [notification.object floatValue] / 100.f;
    }
    NSLog(@">>>> %f", progressNumber);
    [self.progress setProgress:progressNumber animated:YES];
    
    if (progressNumber == 1.f) {
        [self.progressView setHidden:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)createNewReport
{
    [self resignFirstResponder];
    // POST report to server
    @try {
        
        ODMReport *report = [[ODMReport alloc] init];
        report.title = self.titleTextField.text;
        NSError *error = nil;
        
        NSString *title = report.title;
        BOOL isValid = [report validateValue:&title forKey:@"title" error:&error];        
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
//        report.note = self.noteTextField.text;
        report.note = self.noteTextView.text;
        id note = report.note;
        error = nil;
        isValid = [report validateValue:&note forKey:@"note" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        // Attach report photo through HTTP POST protocol
        report.fullImageData = self.bugImage;
        report.thumbnailImageData = [UIImage imageWithCGImage:self.bugImage.CGImage scale:50 orientation:self.bugImage.imageOrientation];
        
        // Add categories to report by associated object
        ODMCategory *category = [ODMCategory categoryWithTitle:self.categoryLabel.text];
        report.categories = [NSArray arrayWithObject:category];
        
        //
        // Place's location
        //
        
        // Add place to report by associated object
        // For validate issue, ARC is not allowed
        // to send object without autorelease
        // so declare new variable to pass object
        // with autorelease variable
        ODMPlace *place = selectedPlace;
        
        // assign to report
        error = nil;
        report.place = place;
        isValid = [report validateValue:&place forKey:@"place" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        
        //
        // Report's location
        // 
        
        // Retrieve location from NSUserDefault
        CLLocation *location = [_locationManager location];
        
        if (self.pictureLocation.coordinate.latitude && self.pictureLocation.coordinate.longitude) {
            //
            // Get location from picture
            //
            report.latitude = @(self.pictureLocation.coordinate.latitude);
            report.longitude = @(self.pictureLocation.coordinate.longitude);
            
        } else if (location != nil && location.horizontalAccuracy <= MINIMUN_ACCURACY_DISTANCE && location.verticalAccuracy <= MINIMUN_ACCURACY_DISTANCE) {
            //
            // Location services are enable and
            // already has detected current location
            //
            report.latitude = @(location.coordinate.latitude);
            report.longitude = @(location.coordinate.longitude);
            
        } else if (place) {
            //
            // Worst case
            // We use place's location from provider(foursquare)
            //
            report.latitude = report.place.latitude;
            report.longitude = report.place.longitude;
            
        } else {
            //
            // Location Services are disable
            //
            error = [NSError errorWithDomain:LOCATION_INVALID_TEXT code:3002 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([self class]), self, @"description", NSLocalizedString(LOCATION_INVALID_DESCRIPTION_TEXT, LOCATION_INVALID_DESCRIPTION_TEXT), nil]];
            
            @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        }
        
        //
        // Validate Latitude
        //
        error = nil;
        id latitude = report.latitude;
        isValid = [report validateValue:&latitude forKey:@"latitude" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        //
        // Validate Longitude
        //
        id longitude = report.longitude;
        isValid = [report validateValue:&longitude forKey:@"longitude" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        //
        // Post Report
        //
        if (error) {
            @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        } else {
            // Call DataManager with new report
            [[ODMDataManager sharedInstance] postNewReport:report error:&error];
        }
    }
    @catch (NSException *exception) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CityBug", @"CityBug") message:[exception reason] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - CATEGORY
/**
 * Update Category Label
 */
- (void)updateCategoryList:(ODMCategoryListViewController *)delegate withCategory:(id)category
{
    self.categoryLabel.text = category;
    
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];

    return YES;
}

#pragma mark - PLACE
/**
 * Update Place Label
 */
- (void)didSelectPlace:(ODMPlace *)place
{
    selectedPlace = place;
    self.localtionLabel.text = [place title];
    
    [self.tableView reloadData];
}

#pragma mark - TABLEVIEW

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignFirstResponder];
}

#pragma mark - LocationManager

- (BOOL)startGatheringLocation
{
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:@"CityBug" message:NSLocalizedString(REQUIRE_LOCATION_SERVICES_TEXT, REQUIRE_LOCATION_SERVICES_TEXT) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [locationAlert show];
        return NO;
    }
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    
    [_locationManager startUpdatingLocation];
    
    return YES;
}

- (BOOL)stopGatheringLocation
{
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
        return YES;
    }
    
    return NO;
}


@end
