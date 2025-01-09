//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import TestsFoundation

final class AssignmentListPreferencesViewModelTests: CoreTestCase {
    private var testee: AssignmentListPreferencesViewModel!
    private var gradingPeriods: [GradingPeriod]!
    private var listPreferences: AssignmentListPreferencesViewModel.AssignmentListPreferences?

    override func setUp() {
        super.setUp()

        gradingPeriods = [
            .save(.make(id: "1", title: "Spring"), courseID: "1", in: database.viewContext),
            .save(.make(id: "2", title: "Summer"), courseID: "2", in: database.viewContext),
            .save(.make(id: "3", title: "Autumn"), courseID: "3", in: database.viewContext),
            .save(.make(id: "4", title: "Winter"), courseID: "4", in: database.viewContext)
        ]

        testee = AssignmentListPreferencesViewModel(
            isTeacher: false,
            initialFilterOptionsStudent: AssignmentFilterOptionStudent.allCases,
            initialStatusFilterOptionTeacher: .allAssignments,
            initialFilterOptionTeacher: .allAssignments,
            sortingOptions: AssignmentListViewModel.AssignmentArrangementOptions.allCases,
            initialSortingOption: .dueDate,
            gradingPeriods: gradingPeriods,
            initialGradingPeriod: gradingPeriods.last,
            courseName: "Test Course",
            env: PreviewEnvironment.shared,
            completion: { [weak self] assignmentListPreferences in
                self?.listPreferences = assignmentListPreferences
            }
        )
    }

    func testInitialState() {
        XCTAssertEqual(testee.courseName, "Test Course")
        XCTAssertEqual(testee.gradingPeriods.count, 5)
        XCTAssertEqual(testee.gradingPeriods.map { $0.id }, [nil] + gradingPeriods.map { $0.id })
        XCTAssertEqual(testee.gradingPeriods.filter { $0.id != nil }.map { $0.id }, gradingPeriods.map { $0.id })
        XCTAssertEqual(testee.selectedGradingPeriod, testee.gradingPeriods.last)
        XCTAssertEqual(testee.sortingOptions, AssignmentListViewModel.AssignmentArrangementOptions.allCases)
        XCTAssertTrue(testee.isGradingPeriodsSectionVisible)
        XCTAssertEqual(testee.selectedSortingOption, AssignmentListViewModel.AssignmentArrangementOptions.dueDate)
        XCTAssertEqual(testee.selectedGradingPeriod!.id, gradingPeriods.last?.id)
        XCTAssertEqual(testee.selectedAssignmentFilterOptionsStudent, AssignmentFilterOptionStudent.allCases)
        XCTAssertEqual(testee.selectedStatusFilterOptionTeacher, AssignmentStatusFilterOptionsTeacher.allAssignments)
        XCTAssertEqual(testee.selectedFilterOptionTeacher, AssignmentFilterOptionsTeacher.allAssignments)
    }

    func testDidSelectAssignmentFilterOption() {
        testee.didSelectAssignmentFilterOption(AssignmentFilterOptionStudent.notYetSubmitted, isSelected: false)
        XCTAssertFalse(testee.selectedAssignmentFilterOptionsStudent.contains(AssignmentFilterOptionStudent.notYetSubmitted))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOptionStudent.notYetSubmitted, isSelected: true)
        XCTAssertTrue(testee.selectedAssignmentFilterOptionsStudent.contains(AssignmentFilterOptionStudent.notYetSubmitted))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOptionStudent.toBeGraded, isSelected: false)
        XCTAssertFalse(testee.selectedAssignmentFilterOptionsStudent.contains(AssignmentFilterOptionStudent.toBeGraded))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOptionStudent.toBeGraded, isSelected: true)
        XCTAssertTrue(testee.selectedAssignmentFilterOptionsStudent.contains(AssignmentFilterOptionStudent.toBeGraded))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOptionStudent.graded, isSelected: false)
        XCTAssertFalse(testee.selectedAssignmentFilterOptionsStudent.contains(AssignmentFilterOptionStudent.graded))

        testee.didSelectAssignmentFilterOption(AssignmentFilterOptionStudent.graded, isSelected: true)
        XCTAssertTrue(testee.selectedAssignmentFilterOptionsStudent.contains(AssignmentFilterOptionStudent.graded))
    }

    func testCompletion() {let weakVC = WeakViewController()
        let controller = CoreHostingController(AssignmentListPreferencesScreen(viewModel: testee))
        weakVC.setValue(controller)
        let expectedFilterOptionsStudent: [AssignmentFilterOptionStudent] = [.notYetSubmitted, .noSubmission, .toBeGraded]
        let expectedGradingPeriod = testee.gradingPeriods.filter { $0.id == "3" }.first
        testee.selectedSortingOption = .groupName
        testee.selectedGradingPeriod = expectedGradingPeriod
        testee.didSelectAssignmentFilterOption(.graded, isSelected: false)
        testee.didSelectAssignmentFilterOption(.toBeGraded, isSelected: false)
        testee.didSelectAssignmentFilterOption(.toBeGraded, isSelected: true)
        testee.selectedFilterOptionTeacher = .needsGrading
        testee.selectedStatusFilterOptionTeacher = .published
        testee.didTapDone(viewController: weakVC)
        testee.didDismiss()

        guard let listPreferences else { return XCTFail() }
        XCTAssertNotNil(listPreferences.filterOptionsStudent)
        XCTAssertEqual(listPreferences.filterOptionsStudent, expectedFilterOptionsStudent)
        XCTAssertNotNil(listPreferences.filterOptionTeacher)
        XCTAssertEqual(listPreferences.filterOptionTeacher, AssignmentFilterOptionsTeacher.needsGrading)
        XCTAssertNotNil(listPreferences.statusFilterOptionTeacher)
        XCTAssertEqual(listPreferences.statusFilterOptionTeacher, AssignmentStatusFilterOptionsTeacher.published)
        XCTAssertNotNil(listPreferences.sortingOption)
        XCTAssertEqual(listPreferences.sortingOption, AssignmentListViewModel.AssignmentArrangementOptions.groupName)
        XCTAssertNotNil(listPreferences.gradingPeriodId)
        XCTAssertEqual(listPreferences.gradingPeriodId, expectedGradingPeriod?.id)
    }

    func testDidTapCancel() {
        let weakVC = WeakViewController()
        let controller = CoreHostingController(AssignmentListPreferencesScreen(viewModel: testee))
        weakVC.setValue(controller)
        let expectedFilterOptionsStudent = AssignmentFilterOptionStudent.allCases
        let expectedGradingPeriod = testee.gradingPeriods.last
        testee.selectedSortingOption = .groupName
        testee.selectedGradingPeriod = testee.gradingPeriods.first
        testee.didSelectAssignmentFilterOption(.graded, isSelected: false)
        testee.didSelectAssignmentFilterOption(.toBeGraded, isSelected: false)
        testee.didSelectAssignmentFilterOption(.toBeGraded, isSelected: true)
        testee.selectedFilterOptionTeacher = .needsGrading
        testee.selectedStatusFilterOptionTeacher = .published
        testee.didTapCancel(viewController: weakVC)
        testee.didDismiss()

        guard let listPreferences else { return XCTFail() }
        XCTAssertNotNil(listPreferences.filterOptionsStudent)
        XCTAssertEqual(listPreferences.filterOptionsStudent, expectedFilterOptionsStudent)
        XCTAssertNotNil(listPreferences.filterOptionTeacher)
        XCTAssertEqual(listPreferences.filterOptionTeacher, AssignmentFilterOptionsTeacher.allAssignments)
        XCTAssertNotNil(listPreferences.statusFilterOptionTeacher)
        XCTAssertEqual(listPreferences.statusFilterOptionTeacher, AssignmentStatusFilterOptionsTeacher.allAssignments)
        XCTAssertNotNil(listPreferences.sortingOption)
        XCTAssertEqual(listPreferences.sortingOption, AssignmentListViewModel.AssignmentArrangementOptions.dueDate)
        XCTAssertEqual(listPreferences.gradingPeriodId, expectedGradingPeriod?.id)
    }

    func testAssignmentFilterOptionsTeacher() {
        XCTAssertEqual(AssignmentFilterOptionsTeacher.allAssignments.title, "All Assignments")
        XCTAssertEqual(AssignmentFilterOptionsTeacher.needsGrading.title, "Needs Grading")
        XCTAssertEqual(AssignmentFilterOptionsTeacher.notSubmitted.title, "Not Submitted")
        XCTAssertEqual(AssignmentStatusFilterOptionsTeacher.published.title, "Published")
        XCTAssertEqual(AssignmentStatusFilterOptionsTeacher.unpublished.title, "Unpublished")

        let assignment = Assignment.make()
        assignment.published = false
        assignment.needsGradingCount = 0
        assignment.submissions = nil
        XCTAssertTrue(AssignmentFilterOptionsTeacher.allAssignments.rule(assignment))
        XCTAssertTrue(AssignmentStatusFilterOptionsTeacher.unpublished.rule(assignment))
        XCTAssertFalse(AssignmentStatusFilterOptionsTeacher.published.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionsTeacher.needsGrading.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionsTeacher.notSubmitted.rule(assignment))

        assignment.published = true
        assignment.needsGradingCount = 1
        let submission = Submission.make()
        submission.submittedAt = nil
        submission.type = .online_text_entry
        assignment.submissions = [submission]
        XCTAssertTrue(AssignmentFilterOptionsTeacher.needsGrading.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionsTeacher.notSubmitted.rule(assignment))
        XCTAssertFalse(AssignmentStatusFilterOptionsTeacher.unpublished.rule(assignment))
        XCTAssertTrue(AssignmentStatusFilterOptionsTeacher.published.rule(assignment))

        submission.submittedAt = Clock.now.addDays(-1)
        submission.type = .on_paper
        XCTAssertFalse(AssignmentFilterOptionsTeacher.notSubmitted.rule(assignment))

        submission.type = .online_text_entry
        XCTAssertFalse(AssignmentFilterOptionsTeacher.notSubmitted.rule(assignment))
    }

    func testAssignmentFilterOptionsStudent() {
        XCTAssertTrue(AssignmentFilterOptionStudent.notYetSubmitted == AssignmentFilterOptionStudent.notYetSubmitted)
        XCTAssertTrue(AssignmentFilterOptionStudent.toBeGraded == AssignmentFilterOptionStudent.toBeGraded)
        XCTAssertTrue(AssignmentFilterOptionStudent.graded == AssignmentFilterOptionStudent.graded)
        XCTAssertTrue(AssignmentFilterOptionStudent.noSubmission == AssignmentFilterOptionStudent.noSubmission)

        let assignment = Assignment.make()
        let submission = Submission.make()
        assignment.submissionTypes = [.online_text_entry]
        submission.submittedAt = nil
        assignment.submissions = [submission]
        XCTAssertTrue(AssignmentFilterOptionStudent.notYetSubmitted.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.toBeGraded.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.graded.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.noSubmission.rule(assignment))

        submission.submittedAt = Clock.now.addDays(-1)
        XCTAssertFalse(AssignmentFilterOptionStudent.notYetSubmitted.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionStudent.toBeGraded.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.graded.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.noSubmission.rule(assignment))

        submission.excused = true
        XCTAssertFalse(AssignmentFilterOptionStudent.notYetSubmitted.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.toBeGraded.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionStudent.graded.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionStudent.noSubmission.rule(assignment))

        submission.excused = false
        assignment.submissionTypes = [.on_paper]
        XCTAssertFalse(AssignmentFilterOptionStudent.notYetSubmitted.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionStudent.toBeGraded.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.graded.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionStudent.noSubmission.rule(assignment))

        submission.workflowState = .graded
        submission.score = 1.0
        XCTAssertFalse(AssignmentFilterOptionStudent.notYetSubmitted.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.toBeGraded.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionStudent.graded.rule(assignment))
        XCTAssertTrue(AssignmentFilterOptionStudent.noSubmission.rule(assignment))

        submission.workflowState = .submitted
        submission.score = nil
        assignment.submissionTypes = [.not_graded]
        XCTAssertFalse(AssignmentFilterOptionStudent.notYetSubmitted.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.toBeGraded.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.graded.rule(assignment))
        XCTAssertFalse(AssignmentFilterOptionStudent.noSubmission.rule(assignment))
    }
}
