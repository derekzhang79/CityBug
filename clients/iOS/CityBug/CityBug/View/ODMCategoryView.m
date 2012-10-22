//
//  ODMCategoryView.m
//  CityBug
//
//  Created by tua~* on 10/22/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import "ODMCategoryView.h"

#define BG_IMAGE @"bugs.jpeg"
#define BG_TITLE_IMAGE @"bugs.jpeg"

#define CELL_HEIGHT 106

@implementation ODMCategoryView
{
    UILabel *titleLabel;
    //UIImageView *imageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //background image view
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_HEIGHT, CELL_HEIGHT)];
        [backgroundImageView setImage:[UIImage imageNamed:BG_IMAGE]];
        [self addSubview:backgroundImageView];
        
        //title background image view
        UIImageView *titleBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, CELL_HEIGHT, 26)];
        [titleBackgroundImageView setImage:[UIImage imageNamed:BG_TITLE_IMAGE]];
        [self addSubview:titleBackgroundImageView];
        
        //image view
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_HEIGHT, 80)];
        [self.imageView setImage:[UIImage imageNamed:@"cat1.png"]];
        [self addSubview:self.imageView];
        
        //title
        titleLabel = [[UILabel alloc] initWithFrame:titleBackgroundImageView.frame];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        titleLabel.text = @"category";
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"layout subview");
    titleLabel.text = self.text;
    
    [self.imageView setNeedsDisplay];
    [self.imageView setNeedsLayout];
    
}


@end
