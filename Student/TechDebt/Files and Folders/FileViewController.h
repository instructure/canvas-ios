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
@property (nullable, nonatomic, strong) NSString* courseID;
@property (nullable, nonatomic, strong) NSString* assignmentID;
@property (nonatomic,assign) BOOL showingOldVersion;

@property (nonatomic) float downloadProgress;
@property (nonatomic, copy, nullable) NSURL *url;
@property (nonnull) CKUploadProgressToolbar *progressToolbar;
@property (nonatomic) BOOL showsCancelMessage;

@property (nonatomic, assign) BOOL showsInteractionButton;
@property (nonatomic, nonnull) PageViewEventLoggerLegacySupport* pageViewEventLog;
@property (nonatomic, copy, nonnull) NSString* pageViewEventName;

- (void)fetchFile;
- (void)showDownloadError:(nonnull NSError *)error;
@end
