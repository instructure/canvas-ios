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

@class CKIFile;

@interface SubmissionAttachmentsController : UITableViewController

@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) NSURL *liveURL;
@property (nonatomic, copy) BOOL (^attemptAnnotationsPreview)(CKIFile *, UIViewController *);
@property (copy) dispatch_block_t onTappedResubmit;

@property (weak) UIPopoverController *popoverController;
@property (weak) UIViewController *popoverPresenter;

@end
