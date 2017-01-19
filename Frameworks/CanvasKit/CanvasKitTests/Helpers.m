//
//  XCTestCase+Helpers.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "Helpers.h"

id loadJSONFixture(NSString *fixtureName)
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.instructure.CanvasKitTests"];
    NSString *filePath = [bundle pathForResource:[fixtureName stringByDeletingPathExtension] ofType:@"json"];
    NSCAssert(filePath, @"Cannot find fixture %@.json", fixtureName);
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error) {
        return nil;
    }
    return result;
}
