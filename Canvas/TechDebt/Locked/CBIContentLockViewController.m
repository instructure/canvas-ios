//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
