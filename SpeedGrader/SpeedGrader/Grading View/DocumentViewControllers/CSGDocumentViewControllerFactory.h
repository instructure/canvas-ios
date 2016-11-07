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
// CSGDocumentViewController.h
// Created by Jason Larsen on 5/12/14.
//

#import <Foundation/Foundation.h>
#import "CSGDocumentHandler.h"

@class CANDSubmission;

/**
* Creates a view controller to manage and display a view for a document.
* A document is one piece of a submission. This piece may be
*/
@interface CSGDocumentViewControllerFactory: NSObject

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (Class)viewControllerClassForHandlingSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (UIViewController<CSGDocumentHandler> *)createViewControllerForHandlingSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment;
+ (UIViewController *)createViewControllerForHandlingError;

@end