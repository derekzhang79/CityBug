//
//  ODMSignInViewController.m
//  CityBug
//
//  Created by tua~* on 9/26/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import "ODMSignInViewController.h"
#import "ODMDataManager.h"
#import "ODMUser.h"


@implementation ODMSignInViewController
{
    UIActivityIndicatorView *indicator;
}
- (void)viewDidLoad
{
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(225, 115, 30, 30)];
    [indicator setBackgroundColor:[UIColor clearColor]];
    [indicator setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleGray];
    indicator.hidden = YES;

    [self.view addSubview:indicator];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPage:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
}

- (void)viewDidUnload
{
    usernameTextField = nil;
    passwordTextField = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)magicSignIn:(id)sender
{
//    usernameTextField.text = @"admin";
//    passwordTextField.text = @"qwer4321";
//    
//    [self signInButtonAction:nil];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:@"admin@citybug.in.th" forKey:@"email"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)signInButtonAction:(id)sender
{
    NSLog(@" >> %@ %@ %@ %@", usernameTextField.text, passwordTextField.text , usernameTextField, passwordTextField);
    if (usernameTextField.text == nil || passwordTextField.text == nil || [usernameTextField.text isEqualToString:@""] || [passwordTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No username or password!" message:@"Please fill in username and password" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    } else {
        
        NSString *email = [NSString stringWithFormat:@"%@@opendream.co.th", usernameTextField.text];
        [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:passwordTextField.text forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        NSError *error = nil;
        // use http basic send, nothing
        [[ODMDataManager sharedInstance] signInCityBugUserWithError:&error];
        
        [indicator startAnimating];
        indicator.hidden = NO;
    }
}

- (void)dismissPage:(id)sender
{
    [indicator stopAnimating];
    indicator.hidden = YES;
    
    if ([[ODMDataManager sharedInstance] isAuthenticated] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not sign in" message:@"Wrong username and password combination! Please try again." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
