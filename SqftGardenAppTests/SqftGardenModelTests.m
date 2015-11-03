//
//  SqftGardenModelTests.m
//  GrowSquared
//
//  Created by Matthew Helm on 10/31/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SqftGardenModel.h"

@interface SqftGardenModelTests : XCTestCase

@property (nonatomic) SqftGardenModel *model;
@property (nonatomic) NSDictionary *dict;

@end

@implementation SqftGardenModelTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:@"sampleGarden.txt"];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    self.dict = [jsonArray objectAtIndex:0];
    self.model = [[SqftGardenModel alloc]initWithDict:self.dict];
    
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    //[[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testModelRowCount{
    NSString *rows = [self.dict objectForKey:@"rows"];
    XCTAssertEqual(rows.intValue, self.model.rows);
}

- (void) testModelColumnCount{
    NSString *columns = [self.dict objectForKey:@"columns"];
    XCTAssertEqual(columns.intValue, self.model.columns);
}

- (void) testModelBedStateString{
    XCTAssertEqualObjects([self.dict objectForKey:@"bedstate"], self.model.bedStateArrayString);
}

- (void) testPlantUniqueOnAddPlant{
    //build this
    XCTAssert:YES;
}



@end
