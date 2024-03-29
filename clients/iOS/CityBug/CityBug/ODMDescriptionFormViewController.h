//
//  ODMDescriptionFormViewController.h
//  CityBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMFormFiedViewController.h"
#import "ODMCategoryListViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "ODMPlaceFormViewController.h"


@interface ODMDescriptionFormViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, ODMCategoryListDelegate, ODMPlaceFormDelegate, UIScrollViewDelegate, CLLocationManagerDelegate> {
    CLLocation *_pictureLocation;
}

@property (weak, nonatomic) IBOutlet UIImageView *bugImageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField, *noteTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel, *placeLabel, *localtionLabel;
@property (weak, nonatomic) UIImage *bugImage;

@property (strong, nonatomic) CLLocation *pictureLocation;

- (IBAction)doneButtonTapped:(id)sender;

@end
