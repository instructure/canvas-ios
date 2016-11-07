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
    
    

#import "CKCanvasAPI+Modules.h"
#import "CKCanvasAPI+Private.h"
#import "CKCanvasAPIResponse.h"
#import "CKPaginationInfo.h"
#import "CKModule.h"
#import "CKModuleItem.h"

@implementation CKCanvasAPI (Modules)

- (void)fetchModulesForCourseID:(uint64_t)courseID pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block
{
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/modules?per_page=%d", self.apiProtocol, self.hostname, courseID, self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    [self runForPaginatedURL:url withMapping:^(NSDictionary *info) {
        return [CKModule moduleWithInfo:info];
    } completion:block];
}

- (void)fetchModuleItemsForCourseID:(uint64_t)courseID moduleID:(uint64_t)moduleID pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block
{
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/modules/%qu/items?per_page=%d",
                               self.apiProtocol, self.hostname, courseID, moduleID, self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    [self runForPaginatedURL:url withMapping:^(NSDictionary *info) {
        return [CKModuleItem itemWithInfo:info];
    } completion:block];
}

@end
