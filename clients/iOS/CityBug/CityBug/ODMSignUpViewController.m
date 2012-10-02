//
//  ODMSignUpViewController.m
//  CityBug
//
//  Created by Pirapa on 10/2/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMSignUpViewController.h"
#import "ODMDataManager.h"
#import "ODMUser.h"

@interface ODMSignUpViewController ()

@end

@implementation ODMSignUpViewController
@synthesize userNameTextField;
@synthesize passwordTextField;
@synthesize confirmPasswordTextField;
@synthesize emailTextField;


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
}

- (void)viewDidUnload
{
    [self setUserNameTextField:nil];
    [self setPasswordTextField:nil];
    [self setConfirmPasswordTextField:nil];
    [self setEmailTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)signUpButtonTapped:(id)sender {
    ODMUser *newUser = [ODMUser newUser:userNameTextField.text email:emailTextField.text password:passwordTextField.text];
    [[ODMDataManager sharedInstance] signUpNewUser:newUser];
}
@end
