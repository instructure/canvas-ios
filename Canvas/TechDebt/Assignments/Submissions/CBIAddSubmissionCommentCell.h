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

@class CBIAddSubmissionCommentViewModel, CBIResizableTextView;
@interface CBIAddSubmissionCommentCell : UITableViewCell
@property (nonatomic) CGFloat height;
@property (nonatomic, weak) CBIAddSubmissionCommentViewModel *viewModel;

@property (strong, nonatomic) IBOutlet CBIResizableTextView *resizeableTextView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *attachButton;
@end
