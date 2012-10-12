//
//  ODMListViewController.h
//  CityBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "FDStatusBarNotifierView.h"
#import <CoreLocation/CoreLocation.h>
#import "ODMActivityFeedViewCell.h"

@interface ODMListViewController : UITableViewController<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, ODMActivityFeedViewCellDelegate>

@property (strong, nonatomic) CLLocation *location;

- (IBAction)addButtonTapped:(id)sender;

- (IBAction)refreshButtonTapped:(id)sender;

- (IBAction)signInButtonTapped:(id)sender;


@end
