//
//  GrowLocationManager.m
//  GrowSquared
//
//  Created by Matthew Helm on 11/12/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowLocationManager.h"

@interface GrowLocationManager()


@end

@implementation GrowLocationManager

CLLocationManager *locationManager;

- (id) init{
    self = [super init];
    [self commonInit];
    return self;
}

- (void) commonInit {
    
    locationManager = [[CLLocationManager alloc] init];
    
}

- (BOOL)locationServicesAvailable{
    return [CLLocationManager locationServicesEnabled];
}

- (CLLocation *) getCurrentLocation {
    NSLog(@"start updating location");
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
    CLLocation *location = locationManager.location;
    NSLog(@"location %f %f", location.coordinate.latitude, location.coordinate.longitude);
    //[locationManager stopUpdatingLocation];
    return location;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    //CLLocation *currentLocation = newLocation;
    [locationManager stopUpdatingLocation];
    
}

@end