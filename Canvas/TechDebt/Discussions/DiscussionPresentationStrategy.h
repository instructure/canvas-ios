
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
#import <CanvasKit1/CanvasKit1.h>

@class CKDiscussionTopic;
@class CKContextInfo;

@protocol DiscussionPresentationStrategy <NSObject>

@required

// The title of the discussion tab
- (NSString *)tabTitle;

// The strategy to use for creating new discussions.
- (Class)createDiscussionStrategyClass;

// The method called when making a new canvas API request for discussion topics/announcements/etc.
- (void)requestItemsWithPageURL:(NSURL *)pageURL
                    contextInfo:(CKContextInfo *)contextInfo
                      canvasAPI:(CKCanvasAPI *)canvasAPI
                 resultsHandler:(CKPagedArrayBlock)completion;

- (BOOL)allowsDiscussionCreationForCourse:(CKCourse *)course;

// String to use for confirming deletion of a discussion
- (NSString *)textForConfirmingDeletionOfDiscussion:(CKDiscussionTopic *)discussion;

@optional 

// The string to use for the create new discussion cell on iPad
- (NSString *)textForCreateDiscussionCell;

@end
