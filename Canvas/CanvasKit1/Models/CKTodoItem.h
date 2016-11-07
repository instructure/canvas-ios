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
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum {
    CKTodoItemTypeDefault,
    CKTodoItemTypeGrading,
    CKTodoItemTypeSubmitting
} CKTodoItemType;

typedef enum {
    CKTodoItemContextTypeNone,
    CKTodoItemContextTypeCourse,
    CKTodoItemContextTypeGroup
} CKTodoItemContextType;

@class CKCanvasAPI, CKAssignment,CKCourse;

@interface CKTodoItem : CKModelObject

@property (nonatomic, weak) CKCanvasAPI *api;
@property (nonatomic, assign) CKTodoItemType type;
@property (nonatomic, strong) NSURL *ignoreURL;
@property (nonatomic, strong) NSURL *ignorePermanentlyURL;
@property (nonatomic, strong) CKAssignment *assignment;

// Derived information
@property (readonly, strong) NSString *title;
@property (readonly, strong) NSDate *dueDate;

// Context information
@property (nonatomic, assign) CKTodoItemContextType contextType;
@property (nonatomic, assign) uint64_t courseId;
@property (nonatomic, assign) uint64_t groupId;
@property (nonatomic, weak) CKCourse *course;
@property (nonatomic, strong) NSArray *actionPath;

// TypeGrading
@property (nonatomic, assign) int needsGradingCount;

- (id)initWithInfo:(NSDictionary *)info api:(CKCanvasAPI *)theAPI;
- (void)populateActionPath;

+ (CKTodoItemType)typeForString:(NSString *)typeString;
+ (CKTodoItemContextType)contextTypeForString:(NSString *)contextTypeString;

@end
