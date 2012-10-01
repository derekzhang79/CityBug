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
    usernameTextField.text = @"admin";
    passwordTextField.text = @"qwer4321";
    
    [self signInButtonAction:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"admin@citybug.in.th" forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        
        [self performSegueWithIdentifier:@"presentListSeque" sender:self];
        NSError *error = nil;
        ODMUser *user = [[ODMUser alloc] init];
        // use http basic send, nothing
        user.username = @"";
        user.password = @"";
        [[ODMDataManager sharedInstance] signInWithCityBug:user error:&error];
    }
}

@end
