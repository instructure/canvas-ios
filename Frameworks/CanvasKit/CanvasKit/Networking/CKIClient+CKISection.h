//
//  CKIClient+CKISection.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"
#import "CKICourse.h"

@interface CKIClient (CKISection)

- (RACSignal *)fetchSectionsForCourse:(CKICourse *)course;
- (RACSignal *)fetchSectionWithID:(NSString *)sectionID;

@end
