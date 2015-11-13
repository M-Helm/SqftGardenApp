//
//  GrowLocationManager.h
//  GrowSquared
//
//  Created by Matthew Helm on 11/12/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GrowLocationManager : NSObject <CLLocationManagerDelegate>
- (CLLocation *) getCurrentLocation;
@end
