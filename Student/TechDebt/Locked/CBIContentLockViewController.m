//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
