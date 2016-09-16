//
//  CKRubricView.h
//  CanvasKit
//
//  Created by Mark Suman on 2/13/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
