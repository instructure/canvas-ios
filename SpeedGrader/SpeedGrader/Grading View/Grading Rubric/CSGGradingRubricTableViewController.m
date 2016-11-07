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

#import "CSGGradingRubricTableViewController.h"

#import "CSGAppDataSource.h"
#import "CSGGradingRubricCell.h"
#import "CSGGradingRubricCommentsCell.h"

#import "CSGPlaceholderTextView.h"
#import "UITableViewController+CSGFetchedResultsController.h"

static NSString *const CSGGradingRubricTableViewCellID = @"CSGGradingRubricTableViewCellID";
static NSString *const CSGGradingRubricCommentsTableViewCellID = @"CSGGradingRubricCommentsTableViewCellID";

@interface CSGGradingRubricTableViewController () <UITextViewDelegate>

@property (nonatomic, strong) CSGAppDataSource *dataSource;

@property (nonatomic, strong) NSMutableDictionary *assessmentRatingsDictionary;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *rubricCriteria;

@property (nonatomic, strong) NSMutableDictionary *textViewsDictionary;
@property (nonatomic, strong) NSMutableDictionary *commentsDictionary;

@property (nonatomic, strong) CKIRubricCriterionRating *currentCommentRating;

@property (nonatomic, strong) RACSubject *assessmentChangedSubject;

@property (nonatomic, strong) UILabel *noResultsLabel;

@end

@implementation CSGGradingRubricTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    
    self.textViewsDictionary = [NSMutableDictionary dictionary];
    self.commentsDictionary = [NSMutableDictionary dictionary];
    
    [self setupViews];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    self.noResultsLabel.alpha = ![self.dataSource.assignment.rubricCriterion count];
    return [self.dataSource.assignment.rubricCriterion count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CKIRubricCriterion *criterion = [self rubricCriterionForSection:section];
    // add an extra cell for the comments cell
    return [criterion.ratings count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor csg_gradingRailRubricSectionViewBackgroundColor];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.frame.size.width - 20, view.frame.size.height)];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [view addSubview:textLabel];
    
    CKIRubricCriterion *criterion = [self rubricCriterionForSection:section];
    textLabel.text = [criterion.criterionDescription uppercaseString];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKIRubricCriterionRating *rating = [self rubricCriterionRatingForIndexPath:indexPath];
    if (rating) {
        CSGGradingRubricCell *cell = [tableView dequeueReusableCellWithIdentifier:CSGGradingRubricTableViewCellID forIndexPath:indexPath];
        cell.rubricDescriptionLabel.text = rating.ratingDescription;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 2;
        formatter.roundingMode = NSNumberFormatterRoundUp;
        
        cell.pointsBadge.text = [formatter stringFromNumber:@(rating.points)];
        
        CKIRubricCriterion *rubricCriterion = [self rubricCriterionForSection:indexPath.section];
        CKIRubricCriterionRating *currentRating = [self.assessmentRatingsDictionary objectForKey:rubricCriterion.id];
        
        // set the correct style based on if there is a rating for this cell or not
        if (currentRating && (currentRating.points == rating.points)){
            CGFloat percentage = rating.points/rubricCriterion.points;
            cell.pointsBadge.textColor = [UIColor whiteColor];
            cell.pointsBadge.layer.borderWidth = 0.0f;
            cell.pointsBadge.backgroundColor = [UIColor csg_gradeColorForPercentage:percentage];
        } else {
            cell.pointsBadge.backgroundColor = [UIColor whiteColor];
            cell.pointsBadge.textColor = [UIColor darkGrayColor];
            cell.pointsBadge.layer.borderColor = [RGB(225, 226, 223) CGColor];
            cell.pointsBadge.layer.borderWidth = 1.0f;
        }
        
        return cell;
    }
    else {
        CSGGradingRubricCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CSGGradingRubricCommentsTableViewCellID forIndexPath:indexPath];
        cell.commentsTextView.delegate = self;
        cell.commentsTextView.tag = indexPath.section;
        
        // update text based on current rating in this section
        CKIRubricCriterion *rubricCriterion = [self rubricCriterionForSection:indexPath.section];
        CKIRubricCriterionRating *currentRating = [self.assessmentRatingsDictionary objectForKey:rubricCriterion.id];
        
        if (currentRating.comments != (id)[NSNull null] && currentRating.comments.length) {
            cell.commentsTextView.attributedText = [[NSMutableAttributedString alloc] initWithString:currentRating.comments];
        }else {
            cell.commentsTextView.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
        }
        
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self rubricCriterionRatingForIndexPath:indexPath]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogInfo(@"GRADING RUBRIC INDEX SELECTED: %@", indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // create a new rubric assessment if needed
    CKISubmissionRecord *submissionRecord = self.dataSource.selectedSubmissionRecord;
    if (!submissionRecord.rubricAssessment) {
        submissionRecord.rubricAssessment = [CKIRubricAssessment new];
    }
    
    CKIRubricCriterion *criterion = [self rubricCriterionForSection:indexPath.section];
    CKIRubricCriterionRating *rating = [self rubricCriterionRatingForIndexPath:indexPath];
    DDLogInfo(@"CRITERION SELECTED: (%@) - %@", criterion.id, criterion.criterionDescription);
    DDLogInfo(@"RATING SELECTED: (%@) - %@", rating.id, rating.ratingDescription);
    
    
    __block CKIRubricCriterionRating *ratingToUpdate = nil;
    [submissionRecord.rubricAssessment.ratings enumerateObjectsUsingBlock:^(CKIRubricCriterionRating *existingRating, NSUInteger idx, BOOL *stop) {
        if ([existingRating.id isEqualToString:criterion.id]) {
            ratingToUpdate = existingRating;
        }
    }];
    
    // create a new rating for this criterion if needed
    if (!ratingToUpdate) {
        ratingToUpdate = [CKIRubricCriterionRating new];
        ratingToUpdate.id = criterion.id;
        ratingToUpdate.points = rating.points;
        
        NSMutableArray *ratings = [NSMutableArray arrayWithArray:submissionRecord.rubricAssessment.ratings];
        [ratings addObject:ratingToUpdate];
        submissionRecord.rubricAssessment.ratings = [NSArray arrayWithArray:ratings];
    } else {
        ratingToUpdate.points = rating.points;
    }
    
    if (self.dataSource.assignment.useRubricForGrading) {
        __block double score = 0.0f;
        [submissionRecord.rubricAssessment.ratings enumerateObjectsUsingBlock:^(CKIRubricCriterionRating *rating, NSUInteger idx, BOOL *stop) {
             score += rating.points;
        }];
        
        submissionRecord.score = @(score);
    }
    
    [self.assessmentChangedSubject sendNext:submissionRecord];
    self.dataSource.selectedSubmissionGradeOrAssessmentChanged = YES;
    
    [self updateAssessmentDictionary];
    
    [self.tableView reloadData];
}

- (CKIRubricCriterionRating *)rubricCriterionRatingWithID:(NSString *)ident {
    __block CKIRubricCriterionRating *returnRating = nil;

    [self.rubricCriteria enumerateObjectsUsingBlock:^(CKIRubricCriterion *rubricCriteria, NSUInteger idx, BOOL *stop) {
        [rubricCriteria.ratings enumerateObjectsUsingBlock:^(CKIRubricCriterionRating *rating, NSUInteger idx, BOOL *stop) {
            if ([rating.id isEqualToString:ident]) {
                returnRating = rating;
            }
        }];
    }];
    
    return returnRating;
}

- (CKIRubricCriterion *)rubricCriterionForSection:(NSInteger)section {
    return (CKIRubricCriterion *)self.rubricCriteria[section];
}

- (CKIRubricCriterionRating *)rubricCriterionRatingForIndexPath:(NSIndexPath *)indexPath {
    CKIRubricCriterion *criteria = [self rubricCriterionForSection:indexPath.section];
    
    if (indexPath.row >= [criteria.ratings count]) {
        return nil;
    }
    
    NSArray *ratings = [criteria.ratings sortedArrayUsingComparator:^NSComparisonResult(CKIRubricCriterionRating *rating1, CKIRubricCriterionRating *rating2) {
        return [@(rating2.points) compare:@(rating1.points)];
    }];
    return ratings[indexPath.row];
}

- (void)updateAssessmentDictionary {
    NSMutableDictionary *ratingsDict = [NSMutableDictionary new];
    [self.dataSource.selectedSubmissionRecord.rubricAssessment.ratings enumerateObjectsUsingBlock:^(CKIRubricCriterionRating *rating, NSUInteger idx, BOOL *stop) {
        [ratingsDict setObject:rating forKey:rating.id];
    }];
    
    self.assessmentRatingsDictionary = ratingsDict;
}

#pragma mark UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    // set this to animate the height of the comments tableviewcell
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.dataSource.selectedSubmissionGradeOrAssessmentChanged = YES;
    
    CKIRubricCriterion *rubricCriterion = [self rubricCriterionForSection:textView.tag];
    CKIRubricCriterionRating *currentRating = [self.assessmentRatingsDictionary objectForKey:rubricCriterion.id];
    
    // needed for when a user types a comment before giving a grade
    if (!currentRating) {
        CKISubmissionRecord *submissionRecord = self.dataSource.selectedSubmissionRecord;
        if (!submissionRecord.rubricAssessment) {
            submissionRecord.rubricAssessment = [CKIRubricAssessment new];
        }
        currentRating = [CKIRubricCriterionRating new];
        currentRating.id = rubricCriterion.id;
        NSMutableArray *ratings = ([submissionRecord.rubricAssessment.ratings mutableCopy]) ?: [NSMutableArray array];
        [ratings addObject:currentRating];
        submissionRecord.rubricAssessment.ratings = [NSArray arrayWithArray:ratings];
        [self updateAssessmentDictionary];
    }
    currentRating.comments = textView.attributedText.string;
}

#pragma mark - Setup View Methods

- (void)setupViews {
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.backgroundColor = [UIColor csg_gradingRailDefaultBackgroundColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 50.0f;
    
    self.noResultsLabel = [[UILabel alloc] initWithFrame:self.tableView.frame];
    self.noResultsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.noResultsLabel.numberOfLines = 0;
    self.noResultsLabel.backgroundColor = [UIColor clearColor];
    self.noResultsLabel.textColor = RGB(155, 155, 155);
    self.noResultsLabel.font = [UIFont systemFontOfSize:24.0];
    self.noResultsLabel.textAlignment = NSTextAlignmentCenter;
    self.noResultsLabel.text = NSLocalizedString(@"No rubric for this submission", @"No Rubric Description Text");
    self.tableView.backgroundView = self.noResultsLabel;
    
    [self setupRACBindings];
}

- (void)setupRACBindings {
    @weakify(self);
    [RACObserve(self, dataSource.assignment) subscribeNext:^(CKIAssignment *assignment) {
        @strongify(self);
        
        // sort the criterion based on positions
        self.rubricCriteria = [NSMutableArray arrayWithArray:assignment.rubricCriterion];
    }];
    
    [RACObserve(self, dataSource.selectedSubmissionRecord) subscribeNext:^(CKISubmissionRecord *submissionRecord) {
        @strongify(self);
        
        // If there's no submission we hijack the noResultsLabel
        if (!submissionRecord || [submissionRecord isDummySubmission]) {
            self.noResultsLabel.text = NSLocalizedString(@"No submission for this student.", @"No Assignment Description Text");
        } else {
            self.noResultsLabel.text = NSLocalizedString(@"No rubric for this submission.", @"No Rubric Description Text");
        }
        
        [self updateAssessmentDictionary];
        [self.tableView reloadData];
    }];
}

#pragma mark - RAC Methods

- (RACSubject *)assessmentChangedSubject {
    if (!_assessmentChangedSubject) {
        _assessmentChangedSubject = [RACSubject subject];
    }
    return _assessmentChangedSubject;
}

- (RACSignal *)assessmentChangedSignal {
    return self.assessmentChangedSubject;
}

@end
