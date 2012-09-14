//
//  ODMDescriptionViewController.h
//  OpendreamBug
//
//  Created by Pirapa on 9/11/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODMEntry.h"
#import "ODMFormFiedViewController.h"

@interface ODMDescriptionViewController : UIViewController <ODMFormFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bugImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *catergoryLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) NSDictionary *entry;

- (IBAction)doneButtonTapped:(id)sender;

@end
