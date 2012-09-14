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

@interface ODMDescriptionFormViewController ()

@end

@implementation ODMDescriptionFormViewController {
    NSMutableDictionary *entryDict;
}



@synthesize locationTextField;
@synthesize bugImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descTextView.layer.borderWidth = 5.0f;
    self.descTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descTextView.layer.cornerRadius = 5;
    self.descTextView.delegate = self;
    

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (IBAction)doneButtonTapped:(id)sender
{
    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
    
    [dataManager postNewEntry:self.bugImage
                        title:self.titleLabel.text
                         note:self.descTextLabel.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
@end
