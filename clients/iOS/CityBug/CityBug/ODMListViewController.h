//
//  ODMListViewController.h
//  CityBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "FDStatusBarNotifierView.h"
#import <CoreLocation/CoreLocation.h>

@interface ODMListViewController : UITableViewController<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)addButtonTapped:(id)sender;

- (IBAction)refreshButtonTapped:(id)sender;

- (IBAction)signInButtonTapped:(id)sender;


@end
