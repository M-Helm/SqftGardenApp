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
    [self buildZoneArray];
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
            NSString *zone = [responseDict objectForKey:@"data"];
            if(zone.length > 5)zone = @"Not Found";
            NSString *zoneStr = [NSString stringWithFormat:@"Detected Zone: %@ Last Frost: %@",zone, [self getFrostDates:zone]];
            self.zoneView.text = zoneStr;
        });
        
    }failure:^(NSError *error) {
        // error handling here ...
        NSString *zoneStr = [NSString stringWithFormat:@"Detected Zone: Not Found"];
        self.zoneView.text = zoneStr;
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
    self.zoneView = [[UILabel alloc]initWithFrame:CGRectMake(10,105,self.view.frame.size.width-20,44)];
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

-(NSArray *)buildZoneArray{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:@"frost_dates.txt"];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    self.zoneArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    return self.zoneArray;
}

-(NSString *)getFrostDates: (NSString *)zone{
    NSString *frostDate = @"Not Found";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for(int i = 0; i<self.zoneArray.count;i++){
        dict = [self.zoneArray objectAtIndex:i];
        if([zone isEqualToString:[dict objectForKey:@"zone"]]){
            frostDate = [dict objectForKey:@"last_frost"];
        }
    }
    
    return frostDate;
}

@end