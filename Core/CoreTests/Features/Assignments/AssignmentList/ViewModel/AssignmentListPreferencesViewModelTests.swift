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
import XCTest

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

        XCTAssertEqual(testee.studentFilterOptions.all.map(\.id), AssignmentFilterOptionStudent.allCases.map(\.id))
        XCTAssertEqual(Set(testee.studentFilterOptions.selected.value.map(\.id)), Set(AssignmentFilterOptionStudent.allCases.map(\.id)))
        XCTAssertEqual(testee.teacherFilterOptions.all.map(\.id), AssignmentFilterOptionsTeacher.allCases.map(\.rawValue))
        XCTAssertEqual(testee.teacherFilterOptions.selected.value?.id, AssignmentFilterOptionsTeacher.allAssignments.rawValue)
        XCTAssertEqual(testee.teacherPublishStatusFilterOptions.all.map(\.id), AssignmentStatusFilterOptionsTeacher.allCases.map(\.rawValue))
        XCTAssertEqual(testee.teacherPublishStatusFilterOptions.selected.value?.id, AssignmentStatusFilterOptionsTeacher.allAssignments.rawValue)

        XCTAssertEqual(testee.sortModeOptions.all.map(\.id), AssignmentListViewModel.AssignmentArrangementOptions.allCases.map(\.rawValue))
        XCTAssertEqual(testee.sortModeOptions.selected.value?.id, AssignmentListViewModel.AssignmentArrangementOptions.dueDate.rawValue)

        XCTAssertEqual(testee.gradingPeriodOptions.all.count, 5)
        XCTAssertEqual(testee.gradingPeriodOptions.all.first?.title.contains("All"), true)
        XCTAssertEqual(testee.gradingPeriodOptions.all.dropFirst().map(\.id), gradingPeriods.map(\.id))
        XCTAssertEqual(testee.gradingPeriodOptions.selected.value?.id, "4")

        XCTAssertEqual(testee.isGradingPeriodsSectionVisible, true)
    }

    func testCompletion() {
        let weakVC = WeakViewController()
        let controller = CoreHostingController(AssignmentListPreferencesScreen(viewModel: testee))
        weakVC.setValue(controller)
        testee.studentFilterOptions.selected.send([.make(id: "notYetSubmitted"), .make(id: "toBeGraded")])
        testee.teacherFilterOptions.selected.send(.make(id: "needsGrading"))
        testee.teacherPublishStatusFilterOptions.selected.send(.make(id: "published"))
        testee.sortModeOptions.selected.send(.make(id: "groupName"))
        testee.gradingPeriodOptions.selected.send(.make(id: "3"))

        testee.didTapDone(viewController: weakVC)
        testee.didDismiss()

        guard let listPreferences else { return XCTFail() }
        XCTAssertEqual(
            Set(listPreferences.filterOptionsStudent.map(\.id)),
            Set([AssignmentFilterOptionStudent.notYetSubmitted, AssignmentFilterOptionStudent.toBeGraded].map(\.id))
        )
        XCTAssertEqual(listPreferences.filterOptionTeacher, .needsGrading)
        XCTAssertEqual(listPreferences.statusFilterOptionTeacher, .published)
        XCTAssertEqual(listPreferences.sortingOption, .groupName)
        XCTAssertEqual(listPreferences.gradingPeriodId, "3")
    }

    func testDidTapCancel() {
        let weakVC = WeakViewController()
        let controller = CoreHostingController(AssignmentListPreferencesScreen(viewModel: testee))
        weakVC.setValue(controller)
        testee.studentFilterOptions.selected.send([.make(id: "notYetSubmitted"), .make(id: "toBeGraded")])
        testee.teacherFilterOptions.selected.send(.make(id: "needsGrading"))
        testee.teacherPublishStatusFilterOptions.selected.send(.make(id: "published"))
        testee.sortModeOptions.selected.send(.make(id: "groupName"))
        testee.gradingPeriodOptions.selected.send(.make(id: "3"))

        testee.didTapCancel(viewController: weakVC)
        testee.didDismiss()

        guard let listPreferences else { return XCTFail() }
        XCTAssertEqual(
            Set(listPreferences.filterOptionsStudent.map(\.id)),
            Set(AssignmentFilterOptionStudent.allCases.map(\.id))
        )
        XCTAssertEqual(listPreferences.filterOptionTeacher, .allAssignments)
        XCTAssertEqual(listPreferences.statusFilterOptionTeacher, .allAssignments)
        XCTAssertEqual(listPreferences.sortingOption, .dueDate)
        XCTAssertEqual(listPreferences.gradingPeriodId, "4")
    }

    func testAssignmentFilterOptionsTeacher() {
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
