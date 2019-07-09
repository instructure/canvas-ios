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

@class CKRubric, CKRubricAssessment, CKRubricCriterionRating, CKRubricView;

@protocol CKRubricViewDelegate <NSObject>
@optional
- (void)rubricView:(CKRubricView *)rubricView rubricAssessmentDidChange:(CKRubricAssessment *)assessment;
@end

@interface CKRubricView : UIView

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell *rubricCell;
@property (weak) IBOutlet id<CKRubricViewDelegate> delegate;

@property (nonatomic, strong) CKRubric *rubric;
@property (nonatomic, strong) CKRubricAssessment *assessment;
@property (nonatomic, getter = isReadOnly) BOOL readOnly;
@property BOOL forceFreeformMode;

@property (nonatomic, readonly) CGSize contentSize;

- (void)refresh;
- (void)resignControl;

@end
