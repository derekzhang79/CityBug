//
//  ODMSignUpViewController.m
//  CityBug
//
//  Created by Pirapa on 10/2/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMSignUpViewController.h"
#import "ODMHelper.h"

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    BOOL passValidate = YES;
    if (![self validateUsername:userNameTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_USERNAME_INVALID_TEXT];
    } else if (![self validateUserLength:userNameTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_USERNAME_INVALID_LENGTH];
    } else if (![self validatePasswordLength:passwordTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_PASSWORD_LENGTH];
    } else if (![self validatePasswordLength:confirmPasswordTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_PASSWORD_LENGTH];
    }  else if (![self validatePassword:passwordTextField.text andConfirmPassword:confirmPasswordTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_CONFIRM_PASSWORD_INVALID_TEXT];
    } else if (![self validateEmail:emailTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_EMAIL_INVALID_TEXT];
    }
    
    if (passValidate == NO) {
        [alert show];
    } else {
        
        // do something
        
    }
}

#pragma mark - validation

- (BOOL)validateEmail:(NSString *)checkString
{
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VALIDATION_EMAIL_REGEXR];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)validateUsername:(NSString *)checkString
{
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VALIDATION_USERNAME_REGEXR];
    return [usernameTest evaluateWithObject:checkString];
}

- (BOOL)validatePassword:(NSString *)password andConfirmPassword:(NSString *)confirmPassword
{
    return [password isEqualToString:confirmPassword];
}

- (BOOL)validatePasswordLength:(NSString *)password
{
    return password.length >= MINIMUM_PASSWORD_LENGTH && password.length <= MAXIMUM_PASSWORD_LENGTH;
}

- (BOOL)validateUserLength:(NSString *)username
{
    return username.length >= MINIMUM_USER_LENGTH && username.length <= MAXIMUM_USER_LENGTH;
}

@end
