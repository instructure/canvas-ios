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
    
    

#import "CKRubricView.h"
#import "CKRubric.h"
#import "CKRubricAssessment.h"
#import "CKRubricCriterion.h"
#import "CKRubricCriterionRating.h"
#import "NSArray+CKAdditions.h"
#import <objc/runtime.h>

#define CURRENT_SYSTEM_VERSION_IS_IOS8_PLUS ([[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."][0] intValue] >= 8)

CGFloat iOS7HeightForRowAtIndexPath(CKRubricView *self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath);

@interface CKRubricView () <UITableViewDataSource,UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIView *currentResponder;
@property (nonatomic, strong) NSMutableSet *selectedIndexPaths;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property CGRect rubricCellDescriptionFrame;
@property UIFont *rubricCellDescriptionFont;
@property CGFloat rubricCellDescriptionMargin;
@property NSMutableIndexSet *sectionsWithExpandedComments;

// keeps track of any indexPath to a cell with a custom (not specified in the rubric) grade
@property (nonatomic, strong) NSMutableArray *customGrades;

@end


@implementation CKRubricView


+ (void)initialize {
    [self supportIOS7];
}

+ (void)supportIOS7 {
    if (!CURRENT_SYSTEM_VERSION_IS_IOS8_PLUS) {
        class_addMethod(self, @selector(tableView:heightForRowAtIndexPath:), (IMP)iOS7HeightForRowAtIndexPath, "f@:@@");
    }
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    if (self) {
        [self setUpView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setUpView];
    }
    
    return self;
}

- (void)setUpView
{
    _selectedIndexPaths = [NSMutableSet set];
    _sectionsWithExpandedComments = [NSMutableIndexSet new];
    
    _tableView = [[UITableView alloc] initWithFrame:[self bounds] style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_tableView];
    
    if (CURRENT_SYSTEM_VERSION_IS_IOS8_PLUS) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.f;
    }
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    UINib *cellNib = [UINib nibWithNibName:@"RubricPointsCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"RubricPointsCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (CGSize)contentSize
{
    return self.tableView.contentSize;
}

- (void)refresh
{
    [self setupCustomGrades];
    [self.sectionsWithExpandedComments removeAllIndexes];
    [self.tableView reloadData];
}

- (NSNumberFormatter *)decimalFormatter
{
    if (_decimalFormatter == nil) {
        _decimalFormatter = [[NSNumberFormatter alloc] init];
        _decimalFormatter.roundingIncrement = @0.01;
        _decimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    
    return _decimalFormatter;
}

- (void)resignControl
{
    [self.currentResponder resignFirstResponder];
}

- (BOOL)shouldUseFreeformMode {
    return self.forceFreeformMode || self.rubric.freeFormComments;
}

#pragma mark -

- (void)setRubric:(CKRubric *)rubric
{
    if (_rubric != rubric) {
        [self setupCustomGrades];
    }
    _rubric = rubric;
}

- (void)setAssessment:(CKRubricAssessment *)assessment
{
    if (_assessment != assessment) {
        [self setupCustomGrades];
    }
    _assessment = assessment;
}

#pragma mark - Custom Grades

- (NSMutableArray *)customGrades
{
    if (!_customGrades) {
        _customGrades = [NSMutableArray new];
    }
    return _customGrades;
}

// sets up initial array of index paths where we should be displaying a custom grade
- (void)setupCustomGrades
{
    [self.customGrades removeAllObjects];
    
    for (int section = 0; section < self.rubric.criteria.count; section++) {
        NSInteger count = [[self.rubric.criteria[section] ratings] count];
        
        // if we have a custom score not in the rubric criterion's rating options, add an extra cell for "Custom Grade"
        CKRubricCriterion *criterion = self.rubric.criteria[section];
        
        CKRubricCriterionRating *selectedRating = [self.assessment selectedRatingForCriterion:criterion];
        
        if (!selectedRating || criterion.useRange) {
            [self.customGrades addObject:[NSIndexPath indexPathForRow:count inSection:section]];
        }
    }
}

- (NSIndexPath *)customGradeIndexPathForSection:(NSInteger) section
{
    return (NSIndexPath *)[self.customGrades in_firstObjectPassingTest:^BOOL(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        return obj.section == section;
    }];
}

- (void)removeCustomGradeInSection:(NSInteger)section
{
    // remove any existing custom grade if one of the regular rubric grades was selected
    NSIndexPath *customGrade = [self customGradeIndexPathForSection:section];
    if (customGrade) {
        [self.customGrades removeObject:customGrade];
        [self.tableView deleteRowsAtIndexPaths:@[customGrade] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


// returns nil if false, else returns the index path of the custom grade selected in that section
- (NSIndexPath *)customGradeIsSelectedInSection:(NSInteger) section
{
    __block NSIndexPath *indexPath;
    
    [self.customGrades enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        if (obj.section == section) {
            indexPath = obj;
            *stop = YES;
        }
    }];
    
    return indexPath;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.rubric.criteria.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self shouldUseFreeformMode]) {
        // Always just a 'rating' cell and a 'comments' cell
        return 2;
    }
    
    CKRubricCriterion *criterion = self.rubric.criteria[section];
    NSInteger count = [[criterion ratings] count];
    
    // Add a row for the "custom comments" row if the assessment can be edited, or if there is already
    // a comment provided by the teacher.
    if (self.readOnly == NO || [[self.assessment.ratings[criterion.identifier] comments] length] > 0) {
        count += 1;
    }
    
    // If we have a custom score not in the rubric criterion's rating options, add an extra cell for "Custom Grade"
    if ([self hasCustomGradeForSection:section]) {
        count += 1;
    }
    return count;
    
}

- (BOOL)indexPathIsCommentsPath:(NSIndexPath *)indexPath {
    CKRubricCriterion *criterion = (self.rubric.criteria)[indexPath.section];
    
    if ([self hasCustomGradeForSection:indexPath.section]) {
        return indexPath.row > criterion.ratings.count;
    }
    else {
        return indexPath.row == criterion.ratings.count;
    }
    
}

- (BOOL)hasCustomGradeForSection:(NSInteger)section {
    
    NSIndexPath *customGradeForSection = [self customGradeIndexPathForSection:section];
    
    return customGradeForSection != nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [(self.rubric.criteria)[section] criterionDescription];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self shouldUseFreeformMode] == NO) {
        cell = [self ratingCriterionCellForTableView:tableView atIndexPath:indexPath];
    }
    else {
        cell = [self freeformCriterionCellForTableView:tableView atIndexPath:indexPath];
    }
    
    cell.userInteractionEnabled = ![self isReadOnly];

    NSLog(@"sending a %@ cell", cell.reuseIdentifier);
    
    return cell;
}



- (UITableViewCell *)ratingCriterionCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    static NSString *ratingCellIdentifer = @"RubricRatingWithScoreCell";
    
    CKRubricCriterion *criterion = self.rubric.criteria[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ratingCellIdentifer];
    if (cell == nil) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"RubricViewCell" owner:self options:nil];
        cell = self.rubricCell;
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.rubricCell = nil;
    }

    NSPredicate *dividerIdentifier = [NSPredicate predicateWithFormat:@"%K == %@", @"identifier", @"divider"];
    NSLayoutConstraint *dividerConstraint = [[cell.contentView.constraints filteredArrayUsingPredicate:dividerIdentifier] firstObject];
    [dividerConstraint setConstant:criterion.useRange ? 120 : 42];
    
    NSInteger count = [[self.rubric.criteria[indexPath.section] ratings] count];
    UILabel *pointsLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:2];

    CGFloat fontSize = criterion.useRange ? 15 : 24;
    pointsLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
    
    // if this is a custom grade cell
    if ([self.customGrades containsObject:indexPath]) {
        CKRubricCriterionRating *rating = self.assessment.ratings[criterion.identifier];
        pointsLabel.text = [self.decimalFormatter stringFromNumber:@(rating.points)];
        descriptionLabel.text = criterion.useRange ? NSLocalizedString(@"Score", nil) : NSLocalizedString(@"Custom Grade", @"A custom grade not specified by the rubric.");
        descriptionLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        [self setSelected:YES forRubricRatingCell:cell atIndexPath:indexPath];
    }
    // It's not a custom grade cell, but it's beyond the end of ratings. Must be the comment cell.
    else if (indexPath.row >= count) {
        cell = [self criterionCommentCellForTableView:tableView criterion:criterion atIndexPath:indexPath];
    }
    else {
        CKRubricCriterionRating *rating = criterion.ratings[indexPath.row];
        pointsLabel.text = rating.pointsDescription;
        descriptionLabel.text = rating.ratingDescription;
        
        // is this field selected in the current assessment?
        BOOL currentlySelected = NO;
        if (self.assessment) {
            currentlySelected = [self.assessment isRatingSelected:rating];
        }
        currentlySelected = currentlySelected && !criterion.useRange;
        
        [self setSelected:currentlySelected forRubricRatingCell:cell atIndexPath:indexPath];
    }
    return cell;
}



- (UITableViewCell *)freeformCriterionCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    CKRubricCriterion *criterion = self.rubric.criteria[indexPath.section];
    
    if (indexPath.row == 0) {
        // the score row
        cell = [tableView dequeueReusableCellWithIdentifier:@"RubricPointsCell"];
        
        UITextField *pointsField = (UITextField *)[cell viewWithTag:1];
        UILabel *outOfField = (UILabel *)[cell viewWithTag:2];
        pointsField.delegate = self;
        
        pointsField.text = @"";
        outOfField.text = [NSString stringWithFormat:NSLocalizedString(@"out of %@ points",nil),
                           [self.decimalFormatter stringFromNumber:@(criterion.points)]];
        
        if (self.assessment) {
            CKRubricCriterionRating *rating = self.assessment.ratings[criterion.identifier];
            if (rating) {
                double points = rating.points;
                if (points) {
                    pointsField.text = [self.decimalFormatter stringFromNumber:@(points)];
                }
            }
        }
    }
    else {
        // the comments row
        cell = [self criterionCommentCellForTableView:tableView criterion:criterion atIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)criterionCommentCellForTableView:(UITableView *)tableView criterion:(CKRubricCriterion *)criterion atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RubricCommentsCell"];
    if (cell == nil) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"RubricCommentCell" owner:self options:nil];
        cell = self.rubricCell;
        self.rubricCell = nil;
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    
    label.text = @"";
    
    if (self.assessment) {
        CKRubricCriterionRating *rating = self.assessment.ratings[criterion.identifier];
        if (rating) {
            NSString *comments = rating.comments;
            if (comments) {
                label.text = comments;
            }
        }
    }
    
    return cell;
}

- (void)setSelected:(BOOL)selected forRubricRatingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (!cell) {
        return;
    }
    
    UILabel *pointsLabel = (UILabel *)[cell viewWithTag:1];
    
    if (selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        pointsLabel.textColor = [UIColor blackColor];
        [self.selectedIndexPaths addObject:indexPath];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        pointsLabel.textColor = [UIColor lightGrayColor];
        [self.selectedIndexPaths removeObject:indexPath];
        
        // see if we're unselecting a custom grade, remove it
        NSIndexPath *customGradeIndexPath = [self customGradeIndexPathForSection:indexPath.section];
        if ([indexPath isEqual:customGradeIndexPath]) {
            [self removeCustomGradeInSection:indexPath.section];
        }
    }
}

- (void)setSelected:(BOOL)selected forRubricRatingCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    [self setSelected:selected forRubricRatingCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView endEditing:YES];
    if ([self shouldUseFreeformMode]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UITextField *field = (UITextField *)[cell viewWithTag:1];
            [field becomeFirstResponder];
        }
        
        return;
    }
    
    // don't do anything if they selected a Custom Grade cell
    CKRubricCriterion *criterion = self.rubric.criteria[indexPath.section];
    if (indexPath.row >= criterion.ratings.count) {
        return;
    }
    
    // Deselect a previously selected row in this section
    // (Note that we do an old-school style enumeration here because we may mutate
    // the set while enumerating, and even though we break right after we mutate,
    // NSMutableSet gets mad.)
    NSEnumerator *eachIndexPath = [self.selectedIndexPaths objectEnumerator];
    NSIndexPath *anIndexPath = nil;
    while ((anIndexPath = [eachIndexPath nextObject])) {
        if (anIndexPath.section == indexPath.section) {
            [self setSelected:NO forRubricRatingCellAtIndexPath:anIndexPath];
            break;
        }
    }
    
    [self setSelected:YES forRubricRatingCellAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.assessment) {
        self.assessment = [[CKRubricAssessment alloc] init];
    }
    
    CKRubricCriterionRating *rating = criterion.ratings[indexPath.row];
    
    [self.assessment selectRating:rating];
    
    if ([_delegate respondsToSelector:@selector(rubricView:rubricAssessmentDidChange:)]) {
        [_delegate rubricView:self rubricAssessmentDidChange:self.assessment];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [scrollView endEditing:YES];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text length] > 0) {
        textField.placeholder = textField.text;
        textField.text = @"";
    }
    
    [self scrollSectionVisibleWithView:textField];
    self.currentResponder = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.currentResponder = nil;
    
    NSString *updatedPoints = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.placeholder length] > 0 && [updatedPoints length] == 0) {
        updatedPoints = textField.placeholder;
    }
    
    double points = [updatedPoints doubleValue];
    
    
    NSIndexPath *indexPath = [self indexPathForSubview:textField];
    CKRubricCriterion *criterion = self.rubric.criteria[indexPath.section];
    
    if (points > criterion.points || points < 0) {
        return NO;
    }
    
    [self.assessment setPoints:points forCriterion:criterion];
    
    if ([_delegate respondsToSelector:@selector(rubricView:rubricAssessmentDidChange:)]) {
        [_delegate rubricView:self rubricAssessmentDidChange:self.assessment];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.placeholder length] > 0 && [textField.text length] == 0) {
        textField.text = textField.placeholder;
    }
    textField.placeholder = @"0";
}


#pragma mark -
#pragma mark UITextViewDelegate


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.currentResponder = textView;
    [self scrollSectionVisibleWithView:textView];
    
    UILabel *label = (UILabel *)[textView.superview viewWithTag:2];
    if (label) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        [label setAlpha:0.0];
        [UIView commitAnimations];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    // Now save the contents
    if (!self.rubric) {
        return;
    }
    
    if (!self.assessment) {
        self.assessment = [[CKRubricAssessment alloc] init];
    }
    
    NSIndexPath *indexPath = [self indexPathForSubview:textView];
    if (!indexPath) {
        return;
    }
    
    CKRubricCriterion *criterion = (self.rubric.criteria)[indexPath.section];
    [self.assessment setComment:textView.text forCriterion:criterion];
    
    
    if ([self shouldUseFreeformMode] == NO) {
        [self resizeCellForTextView:textView atIndexPath:indexPath];
    }
    
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.currentResponder = nil;
    
    UILabel *label = (UILabel *)[textView.superview viewWithTag:2];
    if (label && [textView.text isEqual:@""]) {
        label.alpha = 1.0;
    }
}

- (NSIndexPath *)indexPathForSubview:(UIView *)subview {
    // Need to find the cell that the sender is in... is this really the best way to do this?
    UIView *aView = subview;
    do {
        aView = aView.superview;
    } while (aView && ![aView isKindOfClass:[UITableViewCell class]]);
    
    if (!aView) {
        NSLog(@"Couldn't find enclosing UITableViewCell for sender %@", subview);
        return nil;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)aView];
    if (!indexPath) {
        NSLog(@"Couldn't get indexPath for cell of sender %@", subview);
        return nil;
    }
    return indexPath;
}


- (void)resizeCellForTextView:(UITextView *)textView atIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger indexCount = self.sectionsWithExpandedComments.count;
    
    // On non-free-form comment cells, make the comment cells grow dynamically
    CGSize contentSize = textView.contentSize;
    if (contentSize.height > self.tableView.rowHeight) {
        [self.sectionsWithExpandedComments addIndex:indexPath.section];
    }
    else {
        [self.sectionsWithExpandedComments removeIndex:indexPath.section];
    }
    
    if (indexCount != self.sectionsWithExpandedComments.count) {
        // We changed something; update heights.
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        });
    }
}

- (void)scrollSectionVisibleWithView:(UIView *)aView
{
    if (aView && self.rubric && [self shouldUseFreeformMode]) {
        // Find the table cell that this view is hiding in
        UITableViewCell *cell = (id)aView;
        do {
            cell = (id)cell.superview;
        } while (cell && ![cell isKindOfClass:[UITableViewCell class]]);
        
        if (!cell) {
            return;
        }
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (!indexPath) {
            return;
        }
        
        CGRect rectOfRow = [self.tableView rectForRowAtIndexPath:indexPath];
        [self.tableView scrollRectToVisible:rectOfRow animated:YES];
    }
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *)note
{
    [self scrollSectionVisibleWithView:self.currentResponder];
}

@end


CGFloat iOS7HeightForRowAtIndexPath(CKRubricView *self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath) {
    CKRubricCriterion *criterion = (self.rubric.criteria)[indexPath.section];
    
    if ([self shouldUseFreeformMode]) {
        switch (indexPath.row) {
            case 0:
                return self.tableView.rowHeight;
            case 1:
                return 139; // yay magic numbers
        }
    }
    else if ([self indexPathIsCommentsPath:indexPath]) {
        if ([self.sectionsWithExpandedComments containsIndex:indexPath.section]) {
            return self.tableView.rowHeight * 2;
        }
        else {
            return self.tableView.rowHeight;
        }
    }
    else if (indexPath.row < criterion.ratings.count) {
        // Figure out how tall the text label should be and set the row height to that
        if (!(self.rubricCellDescriptionFont)) {
            [[NSBundle bundleForClass:[self class]] loadNibNamed:@"RubricViewCell" owner:self options:nil];
            self.rubricCellDescriptionFrame = [[self.rubricCell viewWithTag:2] frame];
            self.rubricCellDescriptionFont = [(UILabel *)[self.rubricCell viewWithTag:2] font];
            self.rubricCellDescriptionMargin = 13;
            self.rubricCell = nil;
        }
        
        CGSize labelCalculationSize = CGSizeMake(self.rubricCellDescriptionFrame.size.width - self.rubricCellDescriptionMargin, 9999);
        
        UILabel * theLabel = (UILabel *)[self.rubricCell viewWithTag:2];
        
        CGSize descriptionLabelSize = [theLabel sizeThatFits:labelCalculationSize];
        
        CGFloat heightToUse = descriptionLabelSize.height > 44 ? descriptionLabelSize.height + 5 : 44;
        return heightToUse;
        
    }
    return self.tableView.rowHeight;
    
}

