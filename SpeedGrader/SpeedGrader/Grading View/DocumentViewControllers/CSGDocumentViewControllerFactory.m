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
// CSGDocumentViewController.m
// Created by Jason Larsen on 5/12/14.
//


#import "CSGDocumentViewControllerFactory.h"

#import "CSGDocumentHandler.h"

#import "CSGNoSubmissionDocumentViewController.h"
#import "CSGAudioDocumentViewController.h"
#import "CSGImageDocumentViewController.h"
#import "CSGVideoDocumentViewController.h"
#import "CSGWebDocumentViewController.h"
#import "CSGUnsupportedDocumentViewController.h"
#import "CSGErrorDocumentViewController.h"

@interface CSGDocumentViewControllerFactory ()
@property(nonatomic, strong) CANDSubmission *submission;
@end

@implementation CSGDocumentViewControllerFactory

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    Class handlerClass = [self viewControllerClassForHandlingSubmissionRecord:submissionRecord submission:submission attachment:attachment];
    return handlerClass != nil;
}

+ (Class)viewControllerClassForHandlingSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    NSArray *handlers = @[
            CSGNoSubmissionDocumentViewController.class,
            CSGImageDocumentViewController.class,
            CSGAudioDocumentViewController.class,
            CSGVideoDocumentViewController.class,
            CSGWebDocumentViewController.class,
            CSGUnsupportedDocumentViewController.class,
            CSGErrorDocumentViewController.class,
    ];
    
    RACSequence *sequence = [handlers.rac_sequence filter:^BOOL(id<CSGDocumentHandler> handler) {
        return [handler canHandleSubmissionRecord:submissionRecord submission:submission attachment:attachment];
    }];

    return sequence.head;
}

+ (UIViewController<CSGDocumentHandler> *)createViewControllerForHandlingSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    Class handlerClass = [self viewControllerClassForHandlingSubmissionRecord:submissionRecord submission:submission attachment:attachment];
    UIViewController<CSGDocumentHandler> *handler = [handlerClass createWithSubmissionRecord:submissionRecord submission:submission attachment:attachment];
    return handler;
}

+ (UIViewController *)createViewControllerForHandlingError {
    return [CSGErrorDocumentViewController instantiateFromStoryboard];
}

@end