//
//  ODMCommentCell.h
//  CityBug
//
//  Created by tua~* on 10/19/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODMComment.h"

@interface ODMCommentCell : UITableViewCell
{
    UIImageView *_commentUserImageView;
}

@property (nonatomic, weak) ODMComment *comment;
@property (nonatomic, strong) UIImageView *commentUserImageView;


@end
