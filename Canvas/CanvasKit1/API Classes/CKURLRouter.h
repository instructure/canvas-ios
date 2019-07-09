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

#import <Foundation/Foundation.h>
#import "CKCommonTypes.h"

@class CKCanvasAPI;
@class CKCourse;
@class CKAssignment;
@class CKContextInfo;


#pragma mark -
#pragma mark URL Routing
typedef enum {
    CKDestinationURLTypeUnknown,
    
    CKDestinationURLTypeSpeedGraderAssignment,
    
    CKDestinationURLTypeCourse,
    CKDestinationURLTypeAssignment,
    CKDestinationURLTypeDiscussionTopic,
    CKDestinationURLTypeAnnouncement,
    CKDestinationURLTypeFile,
    CKDestinationURLTypeFolder,
    CKDestinationURLTypePage,
    
    CKDestinationURLTypeExternal
} CKDestinationURLType;


@interface CKDestinationInfo : NSObject
@property CKContextInfo *contextInfo;
@property (readonly) CKContextType contextType;
@property (readonly) uint64_t contextIdent;

@property CKDestinationURLType destinationType;
@property NSString *destinationIdentString;
@property (readonly) uint64_t destinationIdent; // nil if non-numeric
@property BOOL destinationIsArray;
@end


@interface CKURLRouter : NSObject

- (NSURL *)canvasURLForURL:(NSURL *)URL;

- (CKDestinationInfo *)destinationInfoForURL:(NSURL *)url;

#pragma mark -
#pragma mark Passing info between CanvasKit applications

+ (NSURL *)speedGraderOpenAssignmentURLWithCourse:(CKCourse *)course andAssignment:(CKAssignment *)assignment;

@end
