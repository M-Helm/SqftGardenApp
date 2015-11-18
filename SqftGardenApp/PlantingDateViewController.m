//
//  PlantingDateViewController.m
//  GrowSquared
//
//  Created by Matthew Helm on 11/18/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//


#import "PlantingDateViewController.h"
#import "GrowToolBarView.h"

@interface PlantingDateViewController()

@end

@implementation PlantingDateViewController
CLLocationManager *locationManager;

-(void)viewDidLoad{
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    [self makeZoneView];
    [self makeToolbar];
    [self getCurrentLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    //CLLocation *currentLocation = newLocation;
    //[self requestHardinessZone:newLocation];
    
    [self requestHardinessZone:newLocation success:^(NSDictionary *responseDict){
        dispatch_async(dispatch_get_main_queue(), ^{
            // do the UI stuff here
            NSString *zoneStr = [NSString stringWithFormat:@"Zone: %@",[responseDict objectForKey:@"data"]];
            self.zoneView.text = zoneStr;
        });
        
    }failure:^(NSError *error) {
        // error handling here ...
    }];
    
    
    [locationManager stopUpdatingLocation];
    
}

- (void)requestHardinessZone:(CLLocation *)location success: (void (^)(NSDictionary * dictionary))completionHandler failure:(void(^)(NSError* error))failure{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:0];
    
    CGFloat lon = location.coordinate.longitude;
    lon *= 100;
    
    CGFloat lat = location.coordinate.latitude;
    lat *= 100;
    
    NSNumber *longitude = [NSNumber numberWithFloat:lon];
    NSNumber *latitude = [NSNumber numberWithFloat:lat];
    
    NSString *url = [NSString stringWithFormat:@"http://growsquared.net/zones/geo/%@/%@",[numberFormatter stringFromNumber:longitude], [numberFormatter stringFromNumber:latitude]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        requestReply = [requestReply stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSLog(@"requestReply: %@", requestReply);
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        if (completionHandler) {
            [dictionary setObject:requestReply forKey:@"data"];
            NSLog(@"block response zone data request: %@", dictionary);
            completionHandler(dictionary);
        }
    }] resume];
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
    return location;
}

-(void)makeZoneView{
    self.zoneView = [[UILabel alloc]initWithFrame:CGRectMake(45,105,100,44)];
    self.zoneView.textColor = [UIColor blackColor];
    self.zoneView.text = @"test";
    [self.view addSubview:self.zoneView];
}

-(void)makeToolbar{
    //added an extra 20 points here because the table view offsets that much
    float toolBarYOrigin = self.view.frame.size.height-44;
    
    GrowToolBarView *toolBar = [[GrowToolBarView alloc] initWithFrame:CGRectMake(0,toolBarYOrigin,self.view.frame.size.width,44) andViewController:self];
    [toolBar setToolBarIsPinned:YES];
    toolBar.canOverrideDate = NO;
    
    //using this to prevent the tool bar from scrolling with tableview. gonna tag it and remove on other vc
    toolBar.tag = 77;
    [self.navigationController.view addSubview:toolBar];
    [toolBar enableBackButton:YES];
    [toolBar enableMenuButton:NO];
    [toolBar enableDateButton:NO];
    [toolBar enableSaveButton:NO];
    [toolBar enableIsoButton:NO];
    [toolBar enableDateOverride:NO];
}

@end