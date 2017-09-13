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
    
    

#import "CBIFileViewController.h"
#import <CanvasKit1/CanvasKit1.h>
#import "CKCanvasAPI+CurrentAPI.h"

@implementation CBIFileViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, fileIdent) = [RACObserve(self, viewModel.model.id)  map:^(NSString *modelID) {
            return @([modelID longLongValue]);
        }];
        
        if ([self.viewModel.model.context isKindOfClass:[CKIGroup class]]) {
            CKIGroup *group = (CKIGroup *)self.viewModel.model.context;
            RAC(self, contextInfo) = [RACObserve(group, id) map:^id(NSString *value) {
                return [CKContextInfo contextInfoFromGroupIdent:[value longLongValue]];
            }];
        } else if ([self.viewModel.model.context isKindOfClass:[CKICourse class]]) {
            CKICourse *course = (CKICourse *)self.viewModel.model.context;
            RAC(self, contextInfo) = [RACObserve(course, id) map:^id(NSString *value) {
                return [CKContextInfo contextInfoFromCourseIdent:[value longLongValue]];
            }];
        }
        
        self.canvasAPI = CKCanvasAPI.currentAPI;
    }
    return self;
}

@end
