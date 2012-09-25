//
//  ODMActivityFeedViewCell.m
//  CityBug
//
//  Created by InICe on 24/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMUser.h"
#import "ODMPlace.h"

#import "ODMActivityFeedViewCell.h"

#import "NSDate+HumanizedTime.h"

#define CELL_VIEW_TAG 4400
#define AVATAR_VIEW_TAG CELL_VIEW_TAG
#define USER_VIEW_TAG CELL_VIEW_TAG+1
#define TITLE_VIEW_TAG CELL_VIEW_TAG+2
#define IMAGE_VIEW_TAG CELL_VIEW_TAG+3
#define PLACE_VIEW_TAG CELL_VIEW_TAG+4
#define IMIN_VIEW_TAG CELL_VIEW_TAG+5
#define LAST_MODIFIED_TAG CELL_VIEW_TAG+6

@implementation ODMActivityFeedViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _avatarImageView = (UIImageView *)[self viewWithTag:AVATAR_VIEW_TAG];
        _avatarImageView.image = [UIImage imageNamed:@"1.jpeg"];
        _reportImageView = (UIImageView *)[self viewWithTag:IMAGE_VIEW_TAG];
        _reportImageView.image = [UIImage imageNamed:@"2.jpeg"];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setReport:(ODMReport *)report
{    
    UILabel *titleLabel = (UILabel *)[self viewWithTag:TITLE_VIEW_TAG];
    titleLabel.text = [report title];
    
    UILabel *userLabel = (UILabel *)[self viewWithTag:USER_VIEW_TAG];
    userLabel.text = [[report user] username];

    UILabel *placeLabel = (UILabel *)[self viewWithTag:PLACE_VIEW_TAG];
    
    placeLabel.text = [[report place] title];
    
    UILabel *iminCountLabel = (UILabel *)[self viewWithTag:IMIN_VIEW_TAG];
    iminCountLabel.text = [report iminString];
    
    UILabel *lastModifiedLabel = (UILabel *)[self viewWithTag:LAST_MODIFIED_TAG];
    lastModifiedLabel.text = [report.lastModified stringWithHumanizedTimeDifference];

    _report = report;
}

@end
