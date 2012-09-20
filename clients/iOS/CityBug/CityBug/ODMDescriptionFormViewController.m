//
//  ODMDescriptionFormViewController.m
//  CityBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMDescriptionFormViewController.h"
#import "ODMDataManager.h"

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
    // POST report to server
    ODMReport *report = [[ODMReport alloc] init];
    report.title = self.titleTextField.text;
    report.note = self.noteTextField.text;
    report.latitude = @13.791343;
    report.longitude = @100.587473;
    report.fullImage = self.bugImage;
    report.thumbnailImage = [UIImage imageWithCGImage:self.bugImage.CGImage scale:0.25 orientation:self.bugImage.imageOrientation];
    
    [[ODMDataManager sharedInstance] postNewReport:report];
    
    [self.navigationController popViewControllerAnimated:YES];
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
