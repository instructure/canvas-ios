//
//  CKURLRouter.h
//  CanvasKit
//
//  Created by Mark Suman on 3/30/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
