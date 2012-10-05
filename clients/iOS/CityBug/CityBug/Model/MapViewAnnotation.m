//
//  MapViewAnnotation.m
//  CityBug
//
//  Created by tua~* on 10/5/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {

	title = ttl;
	coordinate = c2d;
	return self;
}
@end