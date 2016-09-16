//
//  CKIClient+CBIClient.h
//  iCanvas
//
//  Created by Jason Larsen on 11/14/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <CanvasKit/CanvasKit.h>
@import TooLegit;



@interface CKIClient (CBIClient)

/**
* Creates a copy of the client that can be used for fetching images.
*/
- (CKIClient *)imageClient;

@property (nonatomic, readonly) Session *authSession;

@end

extern NSString * const CBICourseColorUpdatedNotification;
extern NSString * const CBICourseColorUpdatedCourseIDKey;
extern NSString * const CBICourseColorUpdatedValue;