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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
