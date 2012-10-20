//
//  ODMCommentCell.m
//  CityBug
//
//  Created by tua~* on 10/19/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import "ODMCommentCell.h"
#import "ODMComment.h"
#import "ODMUser.h"
#import "NSDate+HumanizedTime.h"

#define USERNAME_LABEL_TAG 101
#define USER_IMAGE_VIEW_TAG 102
#define TEXT_LABEL_TAG 103
#define TIME_LABEL_TAG 104

@implementation ODMCommentCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _commentUserImageView = (UIImageView *)[self viewWithTag:USER_IMAGE_VIEW_TAG];
        _commentUserImageView.image = [UIImage imageNamed:@"1.jpeg"];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)setComment:(ODMComment *)comment
{
    UILabel *usernameLabel = (UILabel *)[self viewWithTag:USERNAME_LABEL_TAG];
    usernameLabel.text = [comment user].username;
    
    UILabel *textLabel = (UILabel *)[self viewWithTag:TEXT_LABEL_TAG];
    textLabel.text = comment.text;
    CGRect textFrame = textLabel.frame;
    textFrame.size.height = [self heightForCommentText:comment.text];
    [textLabel setFrame:textFrame];
    
    UILabel *timeLabel = (UILabel *)[self viewWithTag:TIME_LABEL_TAG];
    timeLabel.text = [comment.lastModified stringWithHumanizedTimeDifference];
    
    _comment = comment;
}


- (CGFloat)heightForCommentText:(NSString *)note
{
    // Calculate comment label size
    UIFont *font = [UIFont systemFontOfSize:14.f];
    CGSize constraintSize = CGSizeMake(250, MAXFLOAT);
    CGSize bounds = [note sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeCharacterWrap];
    return bounds.height;

}

@end
