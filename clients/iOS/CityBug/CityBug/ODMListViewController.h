//
//  ODMListViewController.h
//  CityBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "FDStatusBarNotifierView.h"
#import <CoreLocation/CoreLocation.h>

@interface ODMListViewController : UITableViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, StatusBarNotifierViewDelegate>

@property (strong, nonatomic) CLLocation *location;

- (IBAction)addButtonTapped:(id)sender;

- (IBAction)refreshButtonTapped:(id)sender;

@end
