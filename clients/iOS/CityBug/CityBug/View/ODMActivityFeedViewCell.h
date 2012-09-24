//
//  ODMActivityFeedViewCell.h
//  CityBug
//
//  Created by InICe on 24/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMReport.h"

@interface ODMActivityFeedViewCell : UITableViewCell {
    
    UIImageView *_avatarImageView, *_reportImageView;
}

@property (nonatomic, weak) ODMReport *report;
@property (nonatomic, strong) UIImageView *avatarImageView, *reportImageView;

@end
