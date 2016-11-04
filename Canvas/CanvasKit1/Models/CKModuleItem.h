
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
    
    

//
// Created by jasonl on 3/20/13.
//


#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKModuleItemCompletionRequirement;

//"File", "Page", "Discussion", "Assignment", "Quiz", "SubHeader",
// "ExternalUrl", "ExternalTool"

typedef enum CKModuleItemType {
    CKModuleItemTypeFile,
    CKModuleItemTypePage,
    CKModuleItemTypeDiscussion,
    CKModuleItemTypeAssignment,
    CKModuleItemTypeQuiz,
    CKModuleItemTypeSubHeader,
    CKModuleItemTypeExternalURL,
    CKModuleItemTypeExternalTool
} CKModuleItemType;


@interface CKModuleItem : CKModelObject
@property (readonly) uint64_t ident;
@property (readonly) NSString *title;
@property (readonly) NSUInteger indentationLevel;
@property (readonly) NSURL *htmlURL;
@property (readonly) NSURL *canvasObjectURL; //optional
@property (readonly) CKModuleItemCompletionRequirement *completionRequirement;
@property (readonly) CKModuleItemType type;

+ (CKModuleItem *)itemWithInfo:(NSDictionary *)dictionary;
@end