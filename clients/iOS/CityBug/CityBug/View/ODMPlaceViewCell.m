//
//  ODMPlaceViewCell.m
//  CityBug
//
//  Created by tua~* on 10/5/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import "ODMPlaceViewCell.h"
#import "ODMPlace.h"

#define TITLE_VIEW_TAG 101
#define SUBSCRIBE_VIEW_TAG 102

@implementation ODMPlaceViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _subscribeStatusImageView = (UIImageView *)[self viewWithTag:SUBSCRIBE_VIEW_TAG];
        _subscribeStatusImageView.image = [UIImage imageNamed:@"star_inactive"];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)setPlace:(ODMPlace *)place
{
    UILabel *titleLabel = (UILabel *)[self viewWithTag:TITLE_VIEW_TAG];
    titleLabel.text = [place title];
    
    _place = place;
}

@end
