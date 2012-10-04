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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validateFromServerWithNotification:) name:ODMDataManagerNotificationSignUpDidFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPage:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
    
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

- (BOOL)validateTextField
{
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
    } else if (![self validatePassword:passwordTextField.text andConfirmPassword:confirmPasswordTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_CONFIRM_PASSWORD_INVALID_TEXT];
    } else if (![self validateEmail:emailTextField.text]) {
        passValidate = NO;
        [alert setMessage:SIGN_UP_EMAIL_INVALID_TEXT];
    }
    if (passValidate == NO) {
        [alert show];
    }
    return passValidate;

}

- (IBAction)signUpButtonTapped:(id)sender
{    
    if ([self validateTextField]) {
        // send request for registration
        ODMUser *newUser = [ODMUser newUser:userNameTextField.text email:emailTextField.text password:passwordTextField.text thumbnailImage:@""];
        [[ODMDataManager sharedInstance] signUpNewUser:newUser];
    }
}

#pragma mark - validation

- (void)validateFromServerWithNotification:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *result = notification.object;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        
        if ([result isEqualToString:HEADER_TEXT_USERNAME_EXISTED]) {
            [alert setMessage:SIGN_UP_USERNAME_EXISTED];
        } else if ([result isEqualToString:HEADER_TEXT_EMAIL_EXISTED]) {
            [alert setMessage:SIGN_UP_EMAIL_EXISTED];
        }
        [alert show];
    } else {
        //sign up complete!
        [self.navigationController popViewControllerAnimated:YES];
        
        /*
        // Auto sign in
        [[NSUserDefaults standardUserDefaults] setObject:userNameTextField.text forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:passwordTextField.text forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:emailTextField.text forKey:@"email"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSError *error = nil;
        [[ODMDataManager sharedInstance] signInCityBugUserWithError:&error];
         */
    }
}

- (void)dismissPage:(NSNotification *)notification
{
    /*
    // dismiss sign up page
    [self.navigationController popToRootViewControllerAnimated:YES];
     */
}

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
