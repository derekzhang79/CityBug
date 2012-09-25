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


@implementation ODMDescriptionFormViewController {
    NSMutableDictionary *entryDict;
    ODMPlace *selectedPlace;
}

@synthesize bugImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bugImageView.image = self.bugImage;
}

- (void)viewDidUnload
{
    [self setBugImageView:nil];
    [super viewDidUnload];
}

- (IBAction)doneButtonTapped:(id)sender
{
    if ([self createNewReport])
        [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)resignFirstResponder
{
    [self.titleTextField resignFirstResponder];
    [self.noteTextField resignFirstResponder];
    
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

- (BOOL)createNewReport
{
    // POST report to server
    @try {
        
        ODMReport *report = [[ODMReport alloc] init];
        report.title = self.titleTextField.text;
        NSError *error = nil;
        
        id title = report.title;
        BOOL isValid = [report validateValue:&title forKey:@"title" error:&error];
        
        ODMLog(@"error %@ : description %@", error, [[error userInfo] objectForKey:@"description"]);
        
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        report.note = self.noteTextField.text;
        id note = report.note;
        error = nil;
        isValid = [report validateValue:&note forKey:@"note" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        // Attach report photo through HTTP POST protocol
        report.fullImageData = self.bugImage;
        report.thumbnailImageData = [UIImage imageWithCGImage:self.bugImage.CGImage scale:0.25 orientation:self.bugImage.imageOrientation];
        
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
        if (!place) {
            error = [NSError errorWithDomain:PLACE_IS_REQUIRED_FIELD_TEXT code:2001 userInfo:[NSDictionary dictionaryWithKeysAndObjects:NSStringFromClass([ODMReport class]), self, @"description", NSLocalizedString(PLACE_IS_REQUIRED_FIELD_DESCRIPTION_TEXT, PLACE_IS_REQUIRED_FIELD_DESCRIPTION_TEXT), nil]];
            
            @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        }
        
        //
        // Report's location
        //
        
        // Retrieve location from NSUserDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        CLLocation *location = (CLLocation *)[userDefault objectForKey:USER_CURRENT_LOCATION];
        
        report.latitude = @(location.coordinate.latitude);
        report.longitude = @(location.coordinate.longitude);
        
        // Validate Latitude
        error = nil;
        id latitude = report.latitude;
        isValid = [report validateValue:&latitude forKey:@"latitude" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        // Validate Longitude
        id longitude = report.longitude;
        isValid = [report validateValue:&longitude forKey:@"longitude" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        //
        // Post Report
        //
        
        // Call DataManager with new report
        [[ODMDataManager sharedInstance] postNewReport:report error:&error];
        if (error) {
            @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
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
    
    ODMLog(@"Update Category %@", category);
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
    
    ODMLog(@"Update Place %@", [place title]);
}

#pragma mark - TABLEVIEW

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self resignFirstResponder];
}

@end
