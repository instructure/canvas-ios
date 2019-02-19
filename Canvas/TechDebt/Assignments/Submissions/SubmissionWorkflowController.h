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

@class CKAssignment, CKSubmission, CKCanvasAPI, CKContextInfo, CKIAssignment;

@interface SubmissionWorkflowController : NSObject

- (id)initWithViewController:(UIViewController *)viewController;
- (void)present;

@property CKCanvasAPI *canvasAPI;
@property CKIAssignment *assignment;
@property CKAssignment *legacyAssignment;
@property CKContextInfo *contextInfo;
@property (weak, readonly) UIViewController *viewController;

typedef void (^UploadProgressBlock)(float progress); // progress is -1 if indeterminate, else 0..1
typedef void (^UploadCompleteBlock)(CKSubmission *submission, NSError *error);

@property (copy) UploadProgressBlock uploadProgressBlock;
@property (copy) UploadCompleteBlock uploadCompleteBlock;
@property (nonatomic, assign) BOOL allowsMediaSubmission;


@end
