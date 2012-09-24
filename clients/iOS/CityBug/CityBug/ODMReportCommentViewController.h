//
//  ODMReportCommentViewController.h
//  CityBug
//
//  Created by Pirapa on 9/24/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ODMReportCommentDelegate;


@interface ODMReportCommentViewController : UIViewController<UITextFieldDelegate>

- (IBAction)DoneButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *CommentTextField;
@property (unsafe_unretained) id <ODMReportCommentDelegate> delegate;

@end


@protocol ODMReportCommentDelegate <NSObject>

- (void)updateComment:(NSString *)comment;

@end
