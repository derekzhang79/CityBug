//
//  ODMDescriptionFormViewController.m
//  OpendreamBug
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

@synthesize bugImageView;
@synthesize descTextView;
@synthesize locationTextField;
@synthesize bugImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descTextView.layer.borderWidth = 5.0f;
    self.descTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descTextView.layer.cornerRadius = 5;
    self.descTextView.delegate = self;
    
    // self.descTextFieleld.delegate = self;
    self.locationTextField.delegate = self;
    self.bugImageView.image = self.bugImage;
	
}

- (void)viewDidUnload
{
    [self setBugImageView:nil];
    [self setDescTextView:nil];
    [self setLocationTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)doneButtonTapped:(id)sender
{
    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
    
    [dataManager postNewEntry:self.bugImage];
    
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
        self.descTextLabel.text = textField.text;
    } else if ([viewController isKindOfClass:[ODMNoteFormFieldViewController class]]) {
        self.titleLabel.text = textField.text;
    }
    
    [self.tableView reloadData];
}

- (void)updateCategoryList:(ODMCategoryListViewController *)delegate withCategory:(id)category
{
    ODMLog(@"category : %@", category);
    
    self.categoryLabel.text = (NSString *)category;
    
    [self.tableView reloadData];
}

@end
