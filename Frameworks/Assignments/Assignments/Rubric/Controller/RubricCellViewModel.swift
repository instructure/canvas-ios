
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import AssignmentKit
import SoPersistent
import SoLazy
import TooLegit
import ReactiveCocoa
import SoPretty

extension UILabel {
    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
        let attributes = [NSFontAttributeName : font]
        numberOfLines = 0
        lineBreakMode = NSLineBreakMode.ByWordWrapping
        let rect = text!.boundingRectWithSize(CGSizeMake(frame.size.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        heightConstraint.constant = rect.height
        setNeedsLayout()
    }
}

enum RubricCellViewModel: TableViewCellViewModel {
    case Title(NSNumber?, NSNumber)
    case Criterion(String, String)
    case CriterionRating(String, String, NSNumber?, String, Bool)
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .Title(let points, let pointsPossible):
            let cell = tableView.dequeueReusableCellWithIdentifier("rubricPointsPossibleCell") as! PointsPossibleCell

            cell.pointsLabel.text = points == true ? "\(points) / \(pointsPossible)" : "\(pointsPossible)"
            
            cell.pointsTitleLabel.text = NSLocalizedString("Points Possible", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Rubric Points Possible Title")
            
            return cell
        case .Criterion(let criterionDescription, let longDescription):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("RubricCriterionCell") else { fatalError("expected RubricCriterionCell") }
            
            cell.textLabel?.text = criterionDescription.uppercaseString
            cell.detailTextLabel?.text = longDescription
            return cell
        case .CriterionRating( _, let comments, let points, let description, let selected):
            let cell = tableView.dequeueReusableCellWithIdentifier("rubricCriterionRow") as! RubricCriterionRatingCell
            
            cell.lineViewHeight.constant = 1 / UIScreen.mainScreen().scale
            if let points = points {
                cell.pointsLabel.text = points.description
            } else {
                cell.pointsLabel.text = ""
            }
            
            cell.descriptionLabel.text = description
            
            cell.commentsLabel.text = comments
            cell.commentsLabel.hidden = comments.isEmpty
            
            if (comments.isEmpty) {
                cell.descriptionOnlyHeight.priority = 900
                cell.descriptionAndCommentHeight.priority = 250
            } else {
                cell.descriptionOnlyHeight.priority = 250
                cell.descriptionAndCommentHeight.priority = 900
            }
            
            if (selected) {
                cell.pointsLabel.layer.backgroundColor = UIColor(red:0.09, green:0.60, blue:0.85, alpha:1.00).CGColor
                cell.pointsLabel.textColor = UIColor.whiteColor()
            } else {
                cell.pointsLabel.layer.backgroundColor = UIColor.whiteColor().CGColor
                cell.pointsLabel.textColor = UIColor.blackColor()
            }
            cell.pointsLabel.layer.cornerRadius = cell.pointsLabel.frame.height/2
            
            return cell
        }
    }
    
    static func rubricDetails(baseURL: NSURL) -> (rubric: Rubric) -> [RubricCellViewModel] {
        
        return { rubric in
            let assignment = rubric.assignment
            var assessments: Set<RubricAssessment> = []
            
            if let submission = rubric.currentSubmission {
                assessments = submission.assessments
            }
            
            var cells : [RubricCellViewModel] = []
            
            //Title cell for the Rubric (points possible)
            cells += [.Title(assignment.currentScore, rubric.pointsPossible as NSNumber)]
            
            for criterion in rubric.rubricCriterions.sort({$0.position.intValue < $1.position.intValue}) {
                //Section Title for the current Rubric Criterion
                cells += [self.Criterion(criterion.criterionDescription, criterion.longDescription ?? "")]
                
                var customCellViewModel: RubricCellViewModel? = nil
                
                let criterionAssessment: RubricAssessment? = getAssessment(criterion, assessments: assessments)
                let assessmentRating: RubricCriterionRating? = getRating(criterion, assessment: criterionAssessment)
                
                //Turn each rating in the Criterion into cell view models
                cells += criterion.ratings.sort({$0.points.doubleValue > $1.points.doubleValue}).map({ rating -> RubricCellViewModel in
                    var comments = rating.comments
                    var points: NSNumber? = rating.points
                    var highlight = false
                    
                    // If there is an assessment for the current Criterion Rating then modify the cell to reflect the assessment or create a custom cell
                    if let criterionAssessment = criterionAssessment {
                        if let assessmentRating = assessmentRating {
                            if (assessmentRating.id == rating.id) {
                                comments = criterionAssessment.comments
                                points = criterionAssessment.points
                                highlight = true
                            }
                        } else {
                            customCellViewModel = self.customCellViewModel(criterionAssessment)
                        }
                    }
                    
                    return self.CriterionRating(rating.id, comments, points, rating.ratingDescription, highlight)
                })
                
                //Add the custom cell if it is available
                if let customCellViewModel = customCellViewModel {
                    cells += [customCellViewModel]
                }
            }
            
            return cells
        }
    }
    
    static func customCellViewModel(assessment: RubricAssessment) -> RubricCellViewModel? {
        let hasComment = assessment.comments.characters.count > 0
        let hasCustomGrade = assessment.points != nil
        
        if (hasCustomGrade || hasComment) {
            let comment = NSLocalizedString("Comment", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Title for a rating that hasn't been graded but has a comment")
            let noComment = NSLocalizedString("No Comment", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Title for a rating that has custom graded but has no comment")
            return RubricCellViewModel.CriterionRating(assessment.id, assessment.comments, assessment.points, hasComment ? comment : noComment , true)
        }
        
        return nil
    }
    
    //If an assessment exists for the criterion object then get it
    static func getAssessment(criterion: RubricCriterion, assessments: Set<RubricAssessment>) -> RubricAssessment? {
        return assessments.filter({ (assessment) -> Bool in
            return assessment.id == criterion.id
        }).first
    }
    
    //if a rating object exists for a specific criterion assessment then get it
    static func getRating(criterion: RubricCriterion, assessment: RubricAssessment?) -> RubricCriterionRating? {
        guard let assessment = assessment else { return nil }
        return criterion.ratings.filter({ (rating) -> Bool in
            return rating.points == assessment.points
        }).first
    }
}

// MARK: - Equatable

extension RubricCellViewModel: Equatable {}
func ==(lhs: RubricCellViewModel, rhs: RubricCellViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.Title(points1, possible1), .Title(points2, possible2)):
        return points1 == points2 && possible1 == possible2
    case let (.Criterion(description1, longDescription1), .Criterion(description2, longDescription2)):
        return description1 == description2 && longDescription1 == longDescription2
    case let (.CriterionRating(id1, comments1, points1, description1, selected1), .CriterionRating(id2, comments2, points2, description2, selected2)):
        return id1 == id2 && comments1 == comments2 && points1 == points2 && description1 == description2 && selected1 == selected2
    
    default: return false
    }
}
