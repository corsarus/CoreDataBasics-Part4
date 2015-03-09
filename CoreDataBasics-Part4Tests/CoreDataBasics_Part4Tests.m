//
//  CoreDataBasics_Part4Tests.m
//  CoreDataBasics-Part4Tests
//
//  Created by Catalin (iMac) on 05/03/2015.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface CoreDataBasics_Part4Tests : XCTestCase

@end

@implementation CoreDataBasics_Part4Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
