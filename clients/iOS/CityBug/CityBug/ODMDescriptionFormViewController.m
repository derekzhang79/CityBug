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

@implementation ODMDescriptionFormViewController {
    NSMutableDictionary *entryDict;
}

@synthesize locationTextField;
@synthesize bugImage;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationTextField.delegate = self;
    self.bugImageView.image = self.bugImage;

}

- (void)viewDidUnload
{
    [self setBugImageView:nil];
    [self setLocationTextField:nil];
    [super viewDidUnload];
}

- (IBAction)doneButtonTapped:(id)sender
{
    // POST report to server
    ODMReport *report = [[ODMReport alloc] init];
    report.title = @"Post from RestKit";
    report.note = @"Note from RestKit";
    
    [[ODMDataManager sharedInstance] postNewReport:report];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"categorySegueIdentifier"]) {
        ODMCategoryListViewController *formVC = segue.destinationViewController;
        formVC.delegate = self;
    }
}

#pragma mark - FormField Delegate

- (void)updateCategoryList:(ODMCategoryListViewController *)delegate withCategory:(id)category
{
    self.categoryLabel.text = category;
    
    [self.tableView reloadData];
}

@end
