//
//  ODMSignInViewController.h
//  CityBug
//
//  Created by tua~* on 9/26/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

@interface ODMSignInViewController : UIViewController
{
    IBOutlet UITextField *passwordTextField, *usernameTextField;
}

- (IBAction)magicSignIn:(id)sender;
- (IBAction)back:(id)sender;

@end
