//
//  PlantingDateViewController.m
//  GrowSquared
//
//  Created by Matthew Helm on 11/18/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//


#import "PlantingDateViewController.h"
#import "GrowToolBarView.h"
#import "ApplicationGlobals.h"

@interface PlantingDateViewController()

@end

@implementation PlantingDateViewController
CLLocationManager *locationManager;
ApplicationGlobals *appGlobals;

-(void)viewDidLoad{
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    self.datePickerIsOpen = NO;
    [self buildZoneArray];
    [self makeFrostView];
    [self makeFrostButton];
    [self makeZoneView];
    [self makeZoneButton];
    [self makeAcceptButton];
    [self makeToolbar];
    [self getCurrentLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    [self requestHardinessZone:newLocation success:^(NSDictionary *responseDict){
        dispatch_async(dispatch_get_main_queue(), ^{
            // do the UI stuff here
            NSString *zone = [responseDict objectForKey:@"data"];
            if(zone.length > 5){
                zone = @"Not Found";
                self.zoneView.text = @"Detected Zone: NA";
                self.frostView.text = @"Frost Date: NA";
                return;
            }
            NSString *zoneStr = [NSString stringWithFormat:@"Detected Zone: %@",zone];
            NSString *frostDate = [self getFrostDates:zone];
            frostDate = [frostDate substringToIndex:6];
            NSString *frostStr = [NSString stringWithFormat:@"Frost Date: %@", frostDate];
            self.zoneView.text = zoneStr;
             appGlobals.globalGardenModel.zone = zone;
            
            if(![self isModelDateSet]){
                self.frostView.text = frostStr;
                appGlobals.globalGardenModel.frostDate = [self parseDate:[self getFrostDates:zone]];
            }else{
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM dd"];
                frostStr = [NSString stringWithFormat:@"Frost Date: %@",[dateFormatter stringFromDate: appGlobals.globalGardenModel.frostDate]];
                self.frostView.text = frostStr;
            }
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
    self.zoneView = [[UILabel alloc]initWithFrame:CGRectMake(10,
                                                             105,
                                                             ((self.view.frame.size.width/2) - 20),
                                                             44)];
    self.zoneView.textColor = [UIColor blackColor];
    self.zoneView.layer.borderColor =[UIColor blackColor].CGColor;
    self.zoneView.layer.borderWidth = 0;
    [self.zoneView setFont:[UIFont boldSystemFontOfSize:15]];
    self.zoneView.textAlignment = NSTextAlignmentCenter;
    self.zoneView.text = @"Zone: Getting...";
    [self.view addSubview:self.zoneView];
}
-(void)makeZoneButton{
    self.zoneButton = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                              149,
                                                              (self.view.frame.size.width/2) - 20,
                                                              44)];
    self.zoneButton.text = @"Change Zone";
    self.zoneButton.layer.borderWidth = 1;
    self.zoneButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.zoneButton.layer.cornerRadius = 10;
    self.zoneButton.textAlignment = NSTextAlignmentCenter;
    [self.zoneButton setFont:[UIFont systemFontOfSize:15]];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleZoneSingleTap:)];
    [self.zoneButton addGestureRecognizer:singleFingerTap];
    [self.view addSubview:self.zoneButton];
    self.zoneButton.userInteractionEnabled = YES;
}


-(void)makeFrostView{
    self.frostView = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2),
                                                              105,
                                                              ((self.view.frame.size.width/2) - 20),
                                                              44)];
    self.frostView.textColor = [UIColor blackColor];
    self.frostView.layer.borderColor =[UIColor blackColor].CGColor;
    self.frostView.layer.borderWidth = 0;
    [self.frostView setFont:[UIFont boldSystemFontOfSize:15]];
    self.frostView.textAlignment = NSTextAlignmentCenter;
    self.frostView.text = @"Last Frost: Retrieving...";
    self.frostView.text = @"Last Frost: Getting...";

    [self.view addSubview:self.frostView];
}
-(void)makeFrostButton{
    self.frostButton = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2),
                                                                149,
                                                                (self.view.frame.size.width/2) - 20,
                                                                44)];
    self.frostButton.text = @"Change Date";
    self.frostButton.layer.borderWidth = 1;
    self.frostButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.frostButton.layer.cornerRadius = 10;
    self.frostButton.textAlignment = NSTextAlignmentCenter;
    [self.frostButton setFont:[UIFont systemFontOfSize:15]];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleFrostSingleTap:)];
    [self.frostButton addGestureRecognizer:singleFingerTap];
    [self.view addSubview:self.frostButton];
    self.frostButton.userInteractionEnabled = YES;
}
-(void)makeAcceptButton{
    self.acceptButton = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2)- ((self.view.frame.size.width/2) - 20)/2,
                                                                 263,
                                                                 (self.view.frame.size.width/2) - 20,
                                                                 (self.view.frame.size.width/2) - 20)];
    self.acceptButton.text = @"Looks Good";
    self.acceptButton.layer.borderWidth = 1;
    self.acceptButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.acceptButton.layer.cornerRadius = self.acceptButton.frame.size.width/2;
    self.acceptButton.textAlignment = NSTextAlignmentCenter;
    [self.acceptButton setFont:[UIFont boldSystemFontOfSize:18]];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleAcceptSingleTap:)];
    [self.acceptButton addGestureRecognizer:singleFingerTap];
    [self.view addSubview:self.acceptButton];
    self.acceptButton.userInteractionEnabled = YES;
}
- (void)handleAcceptSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"handle accept tap");
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)handleFrostSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"handle frost tap");
    [self showDatePickerView];
}
- (void)handleZoneSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"handle zone tap");
    [self showZonePickerView];
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

-(NSDate *)parseDate: (NSString *)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    NSLog(@"string: %@ date: %@", dateStr, date);
    return date;
}

-(BOOL)isModelDateSet{
    if(appGlobals.globalGardenModel.frostDate != nil){
        NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
        if ([appGlobals.globalGardenModel.frostDate compare:compareDate] == NSOrderedAscending) {
            //no change
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}
-(void) showZonePickerView{
    
    if(self.zonePickerIsOpen){
        [self setZonePickerIsOpen:NO];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.datePickerView.alpha = .0f;
                             self.zonePickerView.alpha = .0f;
                             self.frostButton.alpha = 1.0f;
                             self.zoneButton.alpha = 1.0f;
                             self.acceptButton.alpha = 1.0f;
                             self.zoneView.alpha = 1.0f;
                             self.frostView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             //[self initViews];

                         }];
        return;
    }
    [self setZonePickerIsOpen:YES];
    self.zonePickerView = [[ZoneSelectView alloc] init];
    self.zonePickerView.userInteractionEnabled = YES;
    [self.zonePickerView createZonePicker:self];
    CGRect fm = CGRectMake(10, 80, 300, 216);
    
    //CGRect fm = CGRectMake(self.bedFrameView.frame.origin.x, self.bedFrameView.frame.origin.y, self.bedFrameView.frame.size.width, 44+216);
    self.zonePickerView.frame = fm;
    
    self.zonePickerView.alpha = 1.0f;
    [self.view addSubview:self.zonePickerView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.datePickerView.alpha = 1.0f;
                         self.datePickerView.alpha = 0.0f;
                         self.frostButton.alpha = .0f;
                         self.zoneButton.alpha = .0f;
                         self.acceptButton.alpha = .0f;
                         self.zoneView.alpha = .0f;
                         self.frostView.alpha = .0f;
                     }
                     completion:^(BOOL finished) {
                     }];
}

-(void) showDatePickerView{
    
    if(self.datePickerIsOpen){
        [self setDatePickerIsOpen:NO];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.datePickerView.alpha = .0f;
                             self.zonePickerView.alpha = .0f;
                             self.frostButton.alpha = 1.0f;
                             self.zoneButton.alpha = 1.0f;
                             self.acceptButton.alpha = 1.0f;
                             self.zoneView.alpha = 1.0f;
                             self.frostView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             //[self initViews];
                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                             [dateFormatter setDateFormat:@"MMM dd"];
                             NSString *frostStr = [NSString stringWithFormat:@"Frost Date: %@",[dateFormatter stringFromDate: appGlobals.globalGardenModel.frostDate]];
                             self.frostView.text = frostStr;
                         }];
        return;
    }
    [self setDatePickerIsOpen:YES];
    self.datePickerView = [[DateSelectView alloc] init];
    self.datePickerView.userInteractionEnabled = YES;
    [self.datePickerView createDatePicker:self];
    CGRect fm = CGRectMake((self.view.frame.size.width-315)/2, self.view.frame.origin.y+80, 300, 44+216);
    
    //CGRect fm = CGRectMake(self.bedFrameView.frame.origin.x, self.bedFrameView.frame.origin.y, self.bedFrameView.frame.size.width, 44+216);
    self.datePickerView.frame = fm;
    
    self.datePickerView.alpha = 1.0f;
    [self.view addSubview:self.datePickerView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.datePickerView.alpha = 1.0f;
                         self.frostButton.alpha = .0f;
                         self.zoneButton.alpha = .0f;
                         self.acceptButton.alpha = .0f;
                         self.zoneView.alpha = .0f;
                         self.frostView.alpha = .0f;
                         self.zonePickerView.alpha = .0f;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end