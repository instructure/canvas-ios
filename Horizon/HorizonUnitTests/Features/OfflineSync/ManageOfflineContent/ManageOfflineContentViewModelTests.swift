//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon
import XCTest

final class ManageOfflineContentViewModelTests: HorizonTestCase {

    private static let testData = (
        sessionID: "test-session-1",
        courseID1: "course 1",
        courseID2: "course 2",
        courseName1: "course name 1",
        courseName2: "course name 2",
        courseSize: "5 MB",
        subItemID1: "file 1",
        subItemID2: "file 2"
    )
    private lazy var testData = Self.testData

    private var interactor: ManageOfflineContentInteractorMock!
    private var session: SessionDefaults!
    private var testee: ManageOfflineContentViewModel!

    override func setUp() {
        super.setUp()
        interactor = ManageOfflineContentInteractorMock()
        session = SessionDefaults(sessionID: testData.sessionID)
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        session.reset()
        session = nil
        super.tearDown()
    }

    // MARK: - Loading

    func test_init_shouldLoadCoursesAndHideLoader() {
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, name: testData.courseName1)]

        createTestee()

        XCTAssertEqual(testee.courses.count, 1)
        XCTAssertEqual(testee.courses.first?.id, testData.courseID1)
        XCTAssertEqual(testee.isLoaderVisible, false)
    }

    func test_init_whenInteractorFails_shouldShowError() {
        interactor.shouldFail = true

        createTestee()

        XCTAssertEqual(testee.isErrorVisible, true)
        XCTAssertEqual(testee.isLoaderVisible, false)
        XCTAssertEqual(testee.errorMessage.isEmpty, false)
    }

    // MARK: - selectAllState

    func test_selectAllState_whenNoneSelected_shouldBeUnchecked() {
        interactor.coursesToReturn = [
            makeCourse(id: testData.courseID1, isSelected: false),
            makeCourse(id: testData.courseID2, isSelected: false)
        ]
        createTestee()

        XCTAssertEqual(testee.selectAllState, .unchecked)
    }

    func test_selectAllState_whenAllSelected_shouldBeChecked() {
        interactor.coursesToReturn = [
            makeCourse(id: testData.courseID1, isSelected: true),
            makeCourse(id: testData.courseID2, isSelected: true)
        ]
        createTestee()

        XCTAssertEqual(testee.selectAllState, .checked)
    }

    func test_selectAllState_whenSomeSelected_shouldBePartial() {
        interactor.coursesToReturn = [
            makeCourse(id: testData.courseID1, isSelected: true),
            makeCourse(id: testData.courseID2, isSelected: false)
        ]
        createTestee()

        XCTAssertEqual(testee.selectAllState, .partial)
    }

    // MARK: - toggleSelectAll

    func test_toggleSelectAll_whenPartiallySelected_shouldSelectAllCourses() {
        interactor.coursesToReturn = [
            makeCourse(id: testData.courseID1, isSelected: true),
            makeCourse(id: testData.courseID2, isSelected: false)
        ]
        createTestee()

        testee.toggleSelectAll()

        XCTAssertEqual(testee.courses.allSatisfy { $0.isSelected }, true)
    }

    func test_toggleSelectAll_whenPartiallySelected_withSubItems_shouldSelectAllSubItems() {
        let selectedSubItem = makeSubItem(id: testData.subItemID1, isSelected: true)
        let unselectedSubItem = makeSubItem(id: testData.subItemID2, isSelected: false)
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, subItems: [selectedSubItem, unselectedSubItem])]
        createTestee()

        testee.toggleSelectAll()

        XCTAssertEqual(testee.courses.first?.files.allSatisfy { $0.isSelected }, true)
    }

    func test_toggleSelectAll_whenNoneSelected_shouldSelectAllCourses() {
        interactor.coursesToReturn = [
            makeCourse(id: testData.courseID1, isSelected: false),
            makeCourse(id: testData.courseID2, isSelected: false)
        ]
        createTestee()

        testee.toggleSelectAll()

        XCTAssertEqual(testee.courses.allSatisfy { $0.isSelected }, true)
    }

    func test_toggleSelectAll_whenAllSelected_shouldDeselectAllCourses() {
        interactor.coursesToReturn = [
            makeCourse(id: testData.courseID1, isSelected: true),
            makeCourse(id: testData.courseID2, isSelected: true)
        ]
        createTestee()

        testee.toggleSelectAll()

        XCTAssertEqual(testee.courses.allSatisfy { !$0.isSelected }, true)
    }

    func test_toggleSelectAll_withCoursesThatHaveSubItems_shouldToggleSubItems() {
        let subItem = makeSubItem(id: testData.subItemID1, isSelected: false)
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, subItems: [subItem])]
        createTestee()

        testee.toggleSelectAll()

        XCTAssertEqual(testee.courses.first?.files.allSatisfy { $0.isSelected }, true)
    }

    // MARK: - toggleExpand

    func test_toggleExpand_shouldToggleExpandedState() {
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, isExpanded: false)]
        createTestee()

        testee.toggleExpand(testData.courseID1)

        XCTAssertEqual(testee.courses.first?.isExpanded, true)
    }

    func test_toggleExpand_whenAlreadyExpanded_shouldCollapse() {
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, isExpanded: true)]
        createTestee()

        testee.toggleExpand(testData.courseID1)

        XCTAssertEqual(testee.courses.first?.isExpanded, false)
    }

    func test_toggleExpand_withUnknownID_shouldNotChangeCourses() {
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, isExpanded: false)]
        createTestee()

        testee.toggleExpand("unknown id")

        XCTAssertEqual(testee.courses.first?.isExpanded, false)
    }

    // MARK: - toggleCourse

    func test_toggleCourse_withoutSubItems_shouldSelectCourse() {
        let course = makeCourse(id: testData.courseID1, isSelected: false)
        interactor.coursesToReturn = [course]
        createTestee()

        testee.toggleCourse(course)

        XCTAssertEqual(testee.courses.first?.isSelected, true)
    }

    func test_toggleCourse_whenAlreadySelected_withoutSubItems_shouldDeselectCourse() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)
        interactor.coursesToReturn = [course]
        createTestee()

        testee.toggleCourse(course)

        XCTAssertEqual(testee.courses.first?.isSelected, false)
    }

    func test_toggleCourse_withSubItems_shouldToggleAllSubItems() {
        let subItem1 = makeSubItem(id: testData.subItemID1, isSelected: false)
        let subItem2 = makeSubItem(id: testData.subItemID2, isSelected: false)
        let course = makeCourse(id: testData.courseID1, subItems: [subItem1, subItem2])
        interactor.coursesToReturn = [course]
        createTestee()

        testee.toggleCourse(course)

        XCTAssertEqual(testee.courses.first?.files.allSatisfy { $0.isSelected }, true)
    }

    func test_toggleCourse_withPartiallySelectedSubItems_shouldSelectAllSubItems() {
        let subItem1 = makeSubItem(id: testData.subItemID1, isSelected: true)
        let subItem2 = makeSubItem(id: testData.subItemID2, isSelected: false)
        let course = makeCourse(id: testData.courseID1, subItems: [subItem1, subItem2])
        interactor.coursesToReturn = [course]
        createTestee()

        testee.toggleCourse(course)

        XCTAssertEqual(testee.courses.first?.files.allSatisfy { $0.isSelected }, true)
    }

    func test_toggleCourse_withAllSubItemsSelected_shouldDeselectAllSubItems() {
        let subItem1 = makeSubItem(id: testData.subItemID1, isSelected: true)
        let subItem2 = makeSubItem(id: testData.subItemID2, isSelected: true)
        let course = makeCourse(id: testData.courseID1, subItems: [subItem1, subItem2])
        interactor.coursesToReturn = [course]
        createTestee()

        testee.toggleCourse(course)

        XCTAssertEqual(testee.courses.first?.files.allSatisfy { !$0.isSelected }, true)
    }

    // MARK: - toggleSubItem

    func test_toggleSubItem_shouldToggleSubItemSelection() {
        let subItem = makeSubItem(id: testData.subItemID1, isSelected: false)
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, subItems: [subItem])]
        createTestee()

        testee.toggleSubItem(courseID: testData.courseID1, subItemID: testData.subItemID1)

        XCTAssertEqual(testee.courses.first?.files.first?.isSelected, true)
    }

    func test_toggleSubItem_whenAlreadySelected_shouldDeselect() {
        let subItem = makeSubItem(id: testData.subItemID1, isSelected: true)
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, subItems: [subItem])]
        createTestee()

        testee.toggleSubItem(courseID: testData.courseID1, subItemID: testData.subItemID1)

        XCTAssertEqual(testee.courses.first?.files.first?.isSelected, false)
    }

    func test_toggleSubItem_withUnknownCourseID_shouldNotChangeState() {
        let subItem = makeSubItem(id: testData.subItemID1, isSelected: false)
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, subItems: [subItem])]
        createTestee()

        testee.toggleSubItem(courseID: "unknown id", subItemID: testData.subItemID1)

        XCTAssertEqual(testee.courses.first?.files.first?.isSelected, false)
    }

    func test_toggleSubItem_withUnknownSubItemID_shouldNotChangeState() {
        let subItem = makeSubItem(id: testData.subItemID1, isSelected: false)
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, subItems: [subItem])]
        createTestee()

        testee.toggleSubItem(courseID: testData.courseID1, subItemID: "unknown id")

        XCTAssertEqual(testee.courses.first?.files.first?.isSelected, false)
    }

    // MARK: - pop

    func test_pop_shouldCallRouterDismiss() {
        createTestee()
        let viewController = WeakViewController(UIViewController())

        testee.pop(viewController: viewController)

        wait(for: [router.dismissExpectation], timeout: 1)
    }

    // MARK: - refresh

    func test_refresh_shouldRefetchCoursesIgnoringCache() async {
        interactor.coursesToReturn = [makeCourse(id: testData.courseID1, name: testData.courseName1)]
        createTestee()

        interactor.coursesToReturn = [
            makeCourse(id: testData.courseID1, name: testData.courseName1),
            makeCourse(id: testData.courseID2, name: testData.courseName2)
        ]
        await testee.refresh()

        XCTAssertEqual(testee.courses.count, 2)
    }

    // MARK: - Private helpers

    private func createTestee() {
        testee = ManageOfflineContentViewModel(
            interactor: interactor,
            router: router,
            session: session
        ) {}
    }

    private func makeCourse(
        id: String,
        name: String = "course name",
        isExpanded: Bool = false,
        isSelected: Bool = false,
        subItems: [OfflineFileItem] = []
    ) -> OfflineCourseItem {
        OfflineCourseItem(
            id: id,
            name: name,
            size: testData.courseSize,
            isExpanded: isExpanded,
            isSelected: isSelected,
            subItems: subItems
        )
    }

    private func makeSubItem(
        id: String,
        isSelected: Bool
    ) -> OfflineFileItem {
        OfflineFileItem(
            id: id,
            name: "sub item name",
            size: "1 MB",
            sizeInBytes: 1_000_000,
            isSelected: isSelected,
            mimeClass: "pdf",
            courseID: "121"
        )
    }
}
