//
//  ODMAppDelegate.h
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "KeychainItemWrapper.h"

@interface ODMAppDelegate : UIResponder <UIApplicationDelegate>
{
    KeychainItemWrapper *passwordKeyChainItem;
}
@property (strong, nonatomic) UIWindow *window;

@end
