//
//  CBIContentLockViewController.m
//  iCanvas
//
//  Created by derrick on 2/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIContentLockViewController.h"
#import <CanvasKit1/CanvasKit1.h>
#import "CBILockableViewModel.h"

@implementation CBIContentLockViewController
- (id)initWithViewModel:(CBILockableViewModel *)lockableViewModel {
    
    NSDictionary *lockInfo = [lockableViewModel.model JSONDictionary];
    CKContentLock *lock = [[CKContentLock alloc] initWithInfo:lockInfo];
    
    CKICourse *context = (CKICourse *)lockableViewModel.model.context;
    while (context && ![context isKindOfClass:[CKICourse class]]);
    CKContextInfo *contextInfo = [CKContextInfo contextInfoFromCourseIdent:[context.id longLongValue]];
    
    return [super initWithContentLock:lock itemName:lockableViewModel.lockedItemName inContext:contextInfo];
}
@end
