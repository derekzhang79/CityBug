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
    [self createNewReport];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createNewReport
{
    // POST report to server
    ODMReport *report = [[ODMReport alloc] init];
    report.title = self.titleTextField.text;
    report.note = self.noteTextField.text;
    report.latitude = [NSNumber numberWithDouble:self.location.coordinate.latitude];
    report.longitude = [NSNumber numberWithDouble:self.location.coordinate.longitude];;
    report.fullImage = self.bugImage;
    report.thumbnailImage = [UIImage imageWithCGImage:self.bugImage.CGImage scale:0.25 orientation:self.bugImage.imageOrientation];

    
    
    // Add categories to report by associated object
    ODMCategory *category = [ODMCategory categoryWithTitle:self.categoryLabel.text];
    report.categories = [NSArray arrayWithObject:category];
    
    // Add place to report by associated object
    ODMPlace *place = [ODMPlace placeWithTitle:self.localtionLabel.text latitude:report.latitude longitude:report.longitude uid:@"505a8ef3cea52e3676000001"];
    report.place = place;
    
    // Call DataManager with new report
    [[ODMDataManager sharedInstance] postNewReport:report];
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
    self.localtionLabel.text = [place title];
    
    ODMLog(@"Update Place %@", [place title]);
}

@end
