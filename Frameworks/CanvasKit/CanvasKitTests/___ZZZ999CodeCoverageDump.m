//
//  CodeCoverage.m
//  CanvasKit
//
//  Created by Nathan Lambson on 7/11/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#include <stdio.h>

extern void __gcov_flush();

@interface ___ZZZ999CodeCoverageDump : XCTestCase

@end

@implementation ___ZZZ999CodeCoverageDump

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    __gcov_flush();
}

- (void)testExample {
    XCTAssert(YES, @"Pass");
}

@end
