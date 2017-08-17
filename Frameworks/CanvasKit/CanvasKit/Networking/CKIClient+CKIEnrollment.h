//
//  CKIClient+CKIEnrollment.h
//  CanvasKit
//
//  Created by Derrick Hathaway on 8/8/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <CanvasKit/CanvasKit.h>

@interface CKIClient (CKIEnrollment)
- (RACSignal *)fetchEnrollmentsForCourse:(CKICourse *)course ofTypes:(NSArray *)enrollmentTypes forUserWithID:(NSString *)id;
@end
