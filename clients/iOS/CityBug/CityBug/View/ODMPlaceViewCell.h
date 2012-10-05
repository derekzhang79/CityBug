//
//  ODMPlaceViewCell.h
//  CityBug
//
//  Created by tua~* on 10/5/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ODMPlace;
@interface ODMPlaceViewCell : UITableViewCell
{
    UIImageView *_subscribeStatusImageView;
}

@property (nonatomic, weak) ODMPlace *place;
@property (nonatomic, strong) UIImageView *subscribeStatusImageView;

@end
