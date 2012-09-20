//
//  ODMListViewController.h
//  CityBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ODMListViewController : UITableViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

- (IBAction)addButtonTapped:(id)sender;

- (IBAction)refreshButtonTapped:(id)sender;

@property CLLocation *location;

@end
