//
//  ODMActivityFeedViewCell.h
//  CityBug
//
//  Created by InICe on 24/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMReport.h"
@protocol ODMActivityFeedViewCellDelegate;
@interface ODMActivityFeedViewCell : UITableViewCell {
    __unsafe_unretained id <ODMActivityFeedViewCellDelegate> delegate;
    //UIImageView *_avatarImageView, *_reportImageView;
    
}

@property (unsafe_unretained) id <ODMActivityFeedViewCellDelegate> delegate;
@property (nonatomic, weak) ODMReport *report;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView, *reportImageView;
@property (nonatomic, weak) IBOutlet UIButton *iminButton;
@property (nonatomic, weak) IBOutlet UILabel *iminCountLabel;

@end

@protocol ODMActivityFeedViewCellDelegate <NSObject>

- (void)didClickIminLabelWithReport:(ODMReport *)report;

@end