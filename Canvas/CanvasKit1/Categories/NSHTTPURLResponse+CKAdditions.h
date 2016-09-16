//
//  NSHTTPURLResponse+CKAdditions.h
//  CanvasKit
//
//  Created by BJ Homer on 11/12/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (CKAdditions)

- (NSDictionary *)ck_linkHeaderValues;
- (NSDate *)ck_date;

@end
