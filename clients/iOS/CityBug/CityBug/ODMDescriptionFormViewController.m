//
//  ODMDescriptionFormViewController.m
//  CityBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMDescriptionFormViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ODMDataManager.h"
#import "ODMReport.h"

#import "ODMEditFormFieldViewController.h"
#import "ODMNoteFormFieldViewController.h"
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
    // POST report to server
    ODMReport *report = [[ODMReport alloc] init];
    report.title = self.titleTextField.text;
    report.note = self.noteTextField.text;
    report.fullImage = self.bugImage;
    report.thumbnailImage = [UIImage imageWithCGImage:self.bugImage.CGImage scale:0.25 orientation:self.bugImage.imageOrientation];
    report.lat = self.location.coordinate.latitude;
    report.lng = self.location.coordinate.longitude;
    
    
    [[ODMDataManager sharedInstance] postNewReport:report];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editNoteFormIdentifier"]) {
        ODMFormFiedViewController *formVC = segue.destinationViewController;
        formVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"editTitleFormIdentifier"]) {
        ODMFormFiedViewController *formVC = segue.destinationViewController;
        formVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"categorySegueIdentifier"]) {
        ODMCategoryListViewController *formVC = segue.destinationViewController;
        formVC.delegate = self;
    }
}

#pragma mark - FormField Delegate

- (void)updateFormField:(ODMFormFiedViewController *)viewController withTextField:(UITextField *)textField
{
    ODMLog(@"formfield %@", textField.text);
    
    if ([viewController isKindOfClass:[ODMEditFormFieldViewController class]]) {

    } else if ([viewController isKindOfClass:[ODMNoteFormFieldViewController class]]) {

    }
    
    [self.tableView reloadData];
}

- (void)updateCategoryList:(ODMCategoryListViewController *)delegate withCategory:(id)category
{
    ODMLog(@"category : %@", category);
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
