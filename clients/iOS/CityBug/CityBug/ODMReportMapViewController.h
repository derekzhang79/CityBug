//
//  ODMReportMapViewController.h
//  CityBug
//
//  Created by InICe on 28/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <MapKit/MapKit.h>

@class ODMReport;

@interface ODMReportMapViewController : UIViewController {
    CLLocation *location;
    ODMReport *_report;
}

@property (nonatomic, strong) ODMReport *report;
@property (nonatomic, weak) MKMapView *mapView;
@end
