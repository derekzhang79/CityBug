//
//  ODMListViewController.h
//  CityBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

@interface ODMListViewController : UITableViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)addButtonTapped:(id)sender;

- (IBAction)refreshButtonTapped:(id)sender;

- (IBAction)createNewReport:(id)sender;
@end
