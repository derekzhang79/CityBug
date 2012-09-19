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
//    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
//
//    [dataManager postNewEntry:self.bugImage
//                        title:self.titleLabel.text
//                         note:self.descTextLabel.text];

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

@end
