//
//  CKCanvasAPI+CurrentAPI.h
//  Canvas
//
//  Created by Derrick Hathaway on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import <CanvasKit1/CanvasKit1.h>

@interface CKCanvasAPI (CurrentAPI)
+ (CKCanvasAPI *)currentAPI;
+ (void)updateCurrentAPI;
@end
