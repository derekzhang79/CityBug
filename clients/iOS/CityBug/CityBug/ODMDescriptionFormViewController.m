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
        
        report.latitude = [NSNumber numberWithDouble:self.location.coordinate.latitude];
        report.longitude = [NSNumber numberWithDouble:self.location.coordinate.longitude];
        error = nil;
        
        id latitude = report.latitude;
        isValid = [report validateValue:&latitude forKey:@"latitude" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        id longitude = report.longitude;
        isValid = [report validateValue:&longitude forKey:@"longitude" error:&error];
        if (!isValid || error) @throw [NSException exceptionWithName:[error domain] reason:[[error userInfo] objectForKey:@"description"] userInfo:nil];
        
        report.fullImageData = self.bugImage;
        report.thumbnailImageData = [UIImage imageWithCGImage:self.bugImage.CGImage scale:0.25 orientation:self.bugImage.imageOrientation];
        
        // Add categories to report by associated object
        ODMCategory *category = [ODMCategory categoryWithTitle:self.categoryLabel.text];
        report.categories = [NSArray arrayWithObject:category];
        
        // Add place to report by associated object
        ODMPlace *place = selectedPlace;
        report.place = place;
        
        // Call DataManager with new report
        [[ODMDataManager sharedInstance] postNewReport:report];
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
