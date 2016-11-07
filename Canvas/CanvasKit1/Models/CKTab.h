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
    CKTabTypeUnknown,
    CKTabTypeInternal,
    CKTabTypeExternal
} CKTabType;

@interface CKTab : CKModelObject

@property (readonly) NSString *identStr;
@property (readonly) NSURL *htmlURL;
@property (readonly) NSString *label;
@property (readonly) CKTabType tabType;
@property (readonly) NSURL *externalToolCreateSessionURL;

/**
 * Initialize the CKCourseTab object with the information contained in the info dictionary
 *
 * @param info The dictionary from which to obtain initialization values. The following keys will be used:
 *   'id'
 *   'html_url'
 *   'label'
 *   'type'
 * 'id' is required, and if it is missing, this object will be released and this method will return nil.
 */
- (id)initWithInfo:(NSDictionary *)info;
- (BOOL)hasSameIdentityAs:(NSObject *)object;

@end
