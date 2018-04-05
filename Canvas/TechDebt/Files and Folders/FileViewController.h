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
    
    

#import <UIKit/UIKit.h>
@import CanvasCore;

@class CKUploadProgressToolbar, CKCanvasAPI, CKContextInfo, CKAttachment;

@interface FileViewController : UIViewController <PageViewEventLoggerLegacySupportProtocol>

// needed to load file on own
@property CKCanvasAPI *canvasAPI;
@property CKContextInfo *contextInfo;
@property (nonatomic) CKAttachment *file;
@property uint64_t fileIdent;

// A possible assignment id can be passed through as a query param
@property uint64_t assignmentID;

@property (nonatomic) float downloadProgress;
@property (nonatomic, copy) NSURL *url;
@property CKUploadProgressToolbar *progressToolbar;
@property (nonatomic) BOOL showsCancelMessage;

@property (nonatomic, assign) BOOL showsInteractionButton;
@property (nonatomic) PageViewEventLoggerLegacySupport* pageViewEventLog;
@property (nonatomic, copy) NSString* pageViewEventName;

- (void)showDownloadError:(NSError *)error;

@end
