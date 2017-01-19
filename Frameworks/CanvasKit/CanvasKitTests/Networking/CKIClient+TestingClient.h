//
//  CKIClient+TestingClient.h
//  CanvasKit
//
//  Created by derrick on 9/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@interface CKIClient (TestingClient)

+ (instancetype)testClient;

- (void)returnErrorForPath:(NSString *)path;
- (void)returnResponseObject:(id)responseObject forPath:(NSString *)path;

@end
