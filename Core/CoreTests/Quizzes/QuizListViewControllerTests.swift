//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import XCTest
@testable import Core
import TestsFoundation

class QuizListViewControllerTests: CoreTestCase {
    lazy var controller = QuizListViewController.create(courseID: "1")

    override func setUp() {
        super.setUp()
        api.mock(controller.course, value: .make())
        api.mock(controller.colors, value: .init(custom_colors: [ "course_1": "#0000ff" ]))
        api.mock(controller.quizzes, value: [
            .make(
                assignment_id: "1",
                due_at: DateComponents(calendar: .current, year: 2020, month: 7, day: 20, hour: 14).date,
                id: "1",
                points_possible: 111,
                question_count: 111,
                quiz_type: .assignment,
                title: "A"
            ),
            .make(
                due_at: DateComponents(calendar: .current, year: 2020, month: 3, day: 15).date,
                id: "2",
                lock_at: DateComponents(calendar: .current, year: 2020, month: 3, day: 15).date,
                points_possible: nil,
                quiz_type: .practice_quiz,
                title: "B"
            ),
            .make(
                id: "3",
                quiz_type: .graded_survey,
                title: "C"
            ),
            .make(
                html_url: URL(string: "/courses/1/quizzes/4")!,
                id: "4",
                quiz_type: .survey,
                title: "D"
            ),
        ])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#0000ff")
        XCTAssertEqual(controller.titleSubtitleView.title, "Quizzes")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")

        XCTAssertNoThrow(controller.viewWillDisappear(false))

        var index = IndexPath(row: 0, section: 0)
        var header = controller.tableView.headerView(forSection: index.section) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel.text, "Assignments")
        var cell = controller.tableView.cellForRow(at: index) as? QuizListCell
        XCTAssertEqual(cell?.titleLabel.text, "A")
        XCTAssertEqual(cell?.dateLabel.text, "Due Jul 20, 2020 at 2:00 PM")
        XCTAssertEqual(cell?.pointsLabel.text, "111 pts")
        XCTAssertEqual(cell?.questionsLabel.text, "111 Questions")
        XCTAssertEqual(cell?.statusLabel.isHidden, true)
        XCTAssertEqual(cell?.statusDot.isHidden, true)

        index = IndexPath(row: 0, section: 1)
        header = controller.tableView.headerView(forSection: index.section) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel.text, "Practice Quizzes")
        cell = controller.tableView.cellForRow(at: index) as? QuizListCell
        XCTAssertEqual(cell?.titleLabel.text, "B")
        XCTAssertEqual(cell?.dateLabel.text, "Due Mar 15, 2020 at 12:00 AM")
        XCTAssertEqual(cell?.pointsLabel.text, "Not Graded")
        XCTAssertEqual(cell?.statusLabel.text, "Closed")
        XCTAssertEqual(cell?.statusDot.isHidden, false)

        index = IndexPath(row: 0, section: 2)
        header = controller.tableView.headerView(forSection: index.section) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel.text, "Graded Surveys")
        cell = controller.tableView.cellForRow(at: index) as? QuizListCell
        XCTAssertEqual(cell?.titleLabel.text, "C")
        XCTAssertEqual(cell?.dateLabel.text, "No Due Date")

        index = IndexPath(row: 0, section: 3)
        header = controller.tableView.headerView(forSection: index.section) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel.text, "Surveys")
        cell = controller.tableView.cellForRow(at: index) as? QuizListCell
        XCTAssertEqual(cell?.titleLabel.text, "D")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo(URL(string: "/courses/1/quizzes/4")!))

        api.mock(controller.quizzes, error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)
        XCTAssertEqual(controller.errorView.messageLabel.text, "There was an error loading quizzes. Pull to refresh to try again.")

        api.mock(controller.quizzes, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, true)
        XCTAssertEqual(controller.emptyView.isHidden, false)
        XCTAssertEqual(controller.emptyTitleLabel.text, "No Quizzes")
        XCTAssertEqual(controller.emptyMessageLabel.text, "It looks like quizzes haven’t been created in this space yet.")
    }
}

class QuizListCellTests: CoreTestCase {
    private var testee: QuizListCell!

    override func tearDown() {
        super.tearDown()
        testee = nil
    }

    func testPointsUIWhenQuantitativeDataEnabled() {
        // MARK: GIVEN
        let mock = mockData(restrict_quantitative_data: true)
        loadTestee()

        // MARK: WHEN
        testee.update(quiz: mock.quiz, isTeacher: false, color: nil)

        // MARK: THEN
        XCTAssertTrue(testee.pointsLabel.isHidden)
        XCTAssertTrue(testee.pointsDot.isHidden)
    }

    func testPointsUIWhenQuantitativeDataDisabled() {
        // MARK: GIVEN
        let mock = mockData(restrict_quantitative_data: false)
        loadTestee()

        // MARK: WHEN
        testee.update(quiz: mock.quiz, isTeacher: false, color: nil)

        // MARK: THEN
        XCTAssertFalse(testee.pointsLabel.isHidden)
        XCTAssertFalse(testee.pointsDot.isHidden)
    }

    func testPointsUIWhenQuantitativeDataNotSpecified() {
        // MARK: GIVEN
        let mock = mockData(restrict_quantitative_data: nil)
        loadTestee()

        // MARK: WHEN
        testee.update(quiz: mock.quiz, isTeacher: false, color: nil)

        // MARK: THEN
        XCTAssertFalse(testee.pointsLabel.isHidden)
        XCTAssertFalse(testee.pointsDot.isHidden)
    }

    private func mockData(restrict_quantitative_data: Bool?) -> (course: Course, quiz: Quiz) {
        let quiz = Quiz.save(.make(), in: databaseClient)
        let course = Course.save(.make(settings: .make(restrict_quantitative_data: restrict_quantitative_data)),
                                 in: databaseClient)
        quiz.courseID = course.id
        return (course: course, quiz: quiz)
    }

    private func loadTestee() {
        let host = QuizListViewController.create(courseID: "")
        host.loadViewIfNeeded()
        testee = (host.tableView.dequeueReusableCell(withIdentifier: "QuizListCell") as! QuizListCell)
    }
}
