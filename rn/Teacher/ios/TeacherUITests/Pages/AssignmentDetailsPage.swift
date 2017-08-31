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

import SoGrey
import EarlGrey

class AssignmentDetailsPage  {

    // MARK: Singleton

    static let sharedInstance = AssignmentDetailsPage()
    private let tabBarController = TabBarControllerPage.sharedInstance
    private init() {}

    // MARK: Elements
    private let navBarTitleView = e.selectBy(id: "assignment-details.nav-bar-title-view")
    private let editButton = e.selectBy(id: "assignment-details.edit-btn")
    private let assignmentNameLabel = e.selectBy(id: "assignment-details.assignment-name-lbl")
    private let pointsPossibleLabel = e.selectBy(id: "assignment-details.points-possible-lbl")
    private let publishStatusLabel = e.selectBy(id: "assignment-details.published-icon.publish-status-lbl")
    private let publishedImage = e.selectBy(id: "assignment-details.published-icon.published-status-img")
    private let unpublishedImage = e.selectBy(id: "assignment-details.published-icon.unpublished-status-img")
    private let dueTitleLabel = e.selectBy(id: "assignment-details.assignment-section.due-title-lbl")
    private let dueTitleImage = e.selectBy(id: "assignment-details.assignment-section.due-title-img")
    private let dueDateLabel = e.selectBy(id: "assignment-details.assignment-dates.due-date-lbl")
    private let dueForLabel = e.selectBy(id: "assignment-details.assignment-dates.due-for-lbl")
    private let availableFromLabel = e.selectBy(id: "assignment-details.assignment-dates.available-from-lbl")
    private let availableToLabel = e.selectBy(id: "assignment-details.assignment-dates.available-to-lbl")
    private let submissionTypeTitleLabel = e.selectBy(id: "assignment-details.assignment-section.submission-type-title-lbl")
    private let submissionTypeDetailsLabel = e.selectBy(id: "assignment-details.submission-type.details-lbl")
    private let submissionsTitleLabel = e.selectBy(id: "assignment-details.assignment-section.submissions-title-lbl")
    private let gradedSubmissionGraphTitleLabel = e.selectBy(id: "submissions.submission-graph.graded-title-lbl")
    private let gradedSubmissionGraphProgressView = e.selectBy(id: "submissions.submission-graph.graded-progress-view")
    private let gradedSubmissionDial = e.selectBy(id: "assignment-details.submission-breakdown-graph-section.graded-dial")
    private let ungradedSubmissionGraphTitleLabel = e.selectBy(id: "submissions.submission-graph.ungraded-title-lbl")
    private let ungradedSubmissionGraphProgressView = e.selectBy(id: "submissions.submission-graph.ungraded-progress-view")
    private let ungradedSubmissionDial = e.selectBy(id: "assignment-details.submission-breakdown-graph-section.ungraded-dial")
    private let notSubmittedSubmissionGraphTitleLabel = e.selectBy(id: "submissions.submission-graph.not-submitted-title-lbl")
    private let notSubmittedSubmissionGraphProgressView = e.selectBy(id: "submissions.submission-graph.not-submitted-progress-view")
    private let notSubmittedSubmissionDial = e.selectBy(id: "assignment-details.submission-breakdown-graph-section.not-submitted-dial")
    private let descriptionTitleLabel = e.selectBy(id: "assignment-details.description-section-title-lbl")
    private let descriptionDefaultView = e.selectBy(id: "assignment-details.description-default-view.view")
    private let descriptionWebContainerView = e.selectBy(id: "web-container.view")

    private let backButton = e.selectBy(matchers: [grey_accessibilityLabel("Assignments"),
                                                   grey_accessibilityTrait(UIAccessibilityTraitButton)])

    // MARK: - Assertions

    func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        tabBarController.assertTabBarItems()
        navBarTitleView.assertExists()
        backButton.assertExists()
        editButton.assertExists()
        assignmentNameLabel.assertExists()
        pointsPossibleLabel.assertExists()
        publishStatusLabel.assertExists()
        publishedImage.assertExists()
        dueTitleLabel.assertExists()
        dueTitleImage.assertExists()
        dueDateLabel.assertExists()
        dueForLabel.assertExists()
        availableFromLabel.assertExists()
        availableToLabel.assertExists()
        submissionTypeTitleLabel.assertExists()
        submissionTypeDetailsLabel.assertExists()
        submissionsTitleLabel.assertExists()
        gradedSubmissionGraphTitleLabel.assertExists()
        gradedSubmissionGraphProgressView.assertExists()
        gradedSubmissionDial.assertExists()
        ungradedSubmissionGraphTitleLabel.assertExists()
        ungradedSubmissionGraphProgressView.assertExists()
        ungradedSubmissionDial.assertExists()
        notSubmittedSubmissionGraphTitleLabel.assertExists()
        notSubmittedSubmissionGraphProgressView.assertExists()
        notSubmittedSubmissionDial.assertExists()
    }

    func assertDisplaysInstructions(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        descriptionTitleLabel.assertExists()
        descriptionWebContainerView.assertExists()
    }

    func assertDisplaysNoInstructionsView(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        descriptionDefaultView.assertExists()
    }

    func assertAssignmentDetails(_ assignmentName: String, _ publishStatus: String, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        assignmentNameLabel.assert(grey_accessibilityLabel(assignmentName))
        publishStatusLabel.assert(grey_accessibilityLabel(publishStatus))
    }

    func assertAvailableFromLabel(_ text: String, _ empty: Bool, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        
        if empty {
            availableFromLabel.assert(grey_accessibilityLabel(text))
        } else {
            availableFromLabel.assert(grey_not(grey_accessibilityLabel(text)))
        }
    }

    func assertAvailableToLabel(_ text: String, _ empty: Bool, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        
        if empty {
            availableToLabel.assert(grey_accessibilityLabel(text))
        } else {
            availableToLabel.assert(grey_not(grey_accessibilityLabel(text)))
        }
    }

    func assertSubmissionTypes(_ submissionTypes: [String], _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        for submissionType in submissionTypes {
            submissionTypeDetailsLabel.assertContains(text: submissionType)
        }
    }

    func assertGradedSubmissionGraph(_ amount: Int, _ file: StaticString = #file, _ line: UInt = #line) {
        gradedSubmissionGraphProgressView.assert(
            grey_descendant(grey_allOf([grey_accessibilityLabel("\(amount)"),
                                        grey_accessibilityTrait(UIAccessibilityTraitStaticText)])))
    }

    func assertUngradedSubmissionGraph(_ amount: Int, _ file: StaticString = #file, _ line: UInt = #line) {
        ungradedSubmissionGraphProgressView.assert(
            grey_descendant(grey_allOf([grey_accessibilityLabel("\(amount)"),
                                        grey_accessibilityTrait(UIAccessibilityTraitStaticText)])))
    }

    func assertNotSubmittedSubmissionGraph(_ amount: Int, _ file: StaticString = #file, _ line: UInt = #line) {
        notSubmittedSubmissionGraphProgressView.assert(
            grey_descendant(grey_allOf([grey_accessibilityLabel("\(amount)"),
                                        grey_accessibilityTrait(UIAccessibilityTraitStaticText)])))
    }

    // MARK: - UI Actions

    func dismissToAssignmentListPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        backButton.tapUntilHidden()
    }
}
