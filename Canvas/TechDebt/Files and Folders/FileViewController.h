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
@import QuickLook;

@class CKUploadProgressToolbar, CKCanvasAPI, CKContextInfo, CKAttachment;

@interface FileViewController : UIViewController <PageViewEventLoggerLegacySupportProtocol>

// needed to load file on own
@property (nonnull) CKCanvasAPI *canvasAPI;
@property (nullable) CKContextInfo *contextInfo;
@property (nonatomic, nullable) CKAttachment *file;
@property uint64_t fileIdent;

// These can be passed via routing param or query param
// Route params will be numbers so query params are converted from string to number
@property (nullable, nonatomic, strong) NSNumber* courseID;
@property (nullable, nonatomic, strong) NSNumber* assignmentID;

@property (nonatomic) float downloadProgress;
@property (nonatomic, copy, nullable) NSURL *url;
@property (nonnull) CKUploadProgressToolbar *progressToolbar;
@property (nonatomic) BOOL showsCancelMessage;

@property (nonatomic, assign) BOOL showsInteractionButton;
@property (nonatomic, nonnull) PageViewEventLoggerLegacySupport* pageViewEventLog;
@property (nonatomic, copy, nonnull) NSString* pageViewEventName;

- (void)showDownloadError:(nonnull NSError *)error;
@end
