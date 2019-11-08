//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class PageDetailsPresenterTests: CoreTestCase {
    var presenter: PageDetailsPresenter!
    let context = ContextModel(.course, id: "1")
    let pageURL = "page-test"
    let htmlURL = URL(string: "/courses/1/pages/page-test")!

    let updateExpectation = XCTestExpectation(description: "Update")
    let dismissExpectation = XCTestExpectation(description: "Dismiss")
    let navExpectation = XCTestExpectation(description: "Nav")
    let errorExpectation = XCTestExpectation(description: "Error")

    var resultingSubtitle: String?
    var resultingColor: UIColor?
    var resultingError: Error?

    var color: UIColor?
    var navigationController: UINavigationController?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    override func setUp() {
        super.setUp()
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .student)

    }

    func testUseCasesSetup() {
        XCTAssertEqual(presenter.courses.useCase.courseID, context.id)
        XCTAssertEqual(presenter.groups.useCase.groupID, context.id)
        XCTAssertEqual(presenter.pages.useCase.context.canvasContextID, context.canvasContextID)
        XCTAssertEqual(presenter.pages.useCase.url, presenter.pageURL)
    }

    func testLoadCourseColor() {
        Course.make()
        ContextColor.make()

        presenter.colors.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingColor, UIColor.red)
    }

    func testLoadGroupColor() {
        let group = Group.make()
        ContextColor.make(canvasContextID: group.canvasContextID, color: UIColor.blue)

        presenter.colors.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingColor, UIColor.blue)
    }

    func testLoadCourse() {
        let course = Course.make()

        presenter.courses.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingSubtitle, course.name)
    }

    func testLoadGroup() {
        let group = Group.make()

        presenter.groups.eventHandler()
        wait(for: [navExpectation], timeout: 0.1)

        XCTAssertEqual(resultingSubtitle, group.name)
    }

    func testLoadPage() {
        Page.make(from: .make(
            html_url: htmlURL,
            url: pageURL
        ))

        presenter.pages.eventHandler()
        wait(for: [updateExpectation], timeout: 0.1)

        XCTAssertNotNil(presenter.page)
        XCTAssertEqual(presenter.page?.url, pageURL)
    }

    func testViewIsReadyCourse() {
        presenter.viewIsReady()

        let colorsStore = presenter.colors as! TestStore
        let coursesStore = presenter.courses as! TestStore
        let pagesStore = presenter.pages as! TestStore

        wait(for: [colorsStore.refreshExpectation, coursesStore.refreshExpectation, pagesStore.refreshExpectation], timeout: 1)
    }

    func testViewIsReadyGroup() {
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: ContextModel(.group, id: "1"), pageURL: pageURL, app: .student)
        presenter.viewIsReady()

        let colorsStore = presenter.colors as! TestStore
        let groupsStore = presenter.groups as! TestStore
        let pagesStore = presenter.pages as! TestStore

        wait(for: [colorsStore.refreshExpectation, groupsStore.refreshExpectation, pagesStore.refreshExpectation], timeout: 1)
    }

    func testStudentCantEditTeacherOnlyPage() {
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertFalse(presenter.canEdit())
    }

    func testStudentCanEditTeacherStudentPage() {
        Page.make(from: .make(
            editing_roles: "teachers,students",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertTrue(presenter.canEdit())
    }

    func testStudentCanEditPublicPage() {
        Page.make(from: .make(
            editing_roles: "public",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertTrue(presenter.canEdit())
    }

    func testStudentCanEditMembersPage() {
        Page.make(from: .make(
            editing_roles: "members",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertTrue(presenter.canEdit())
    }

    func testCanEditAsTeacher() {
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .teacher)
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertTrue(presenter.canEdit())
    }

    func testCanEditAsOther() {
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .parent)
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertFalse(presenter.canEdit())
    }

    func testCanDeleteOnlyAsTeacher() {
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .teacher)
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertTrue(presenter.canDelete())

        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .student)
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertFalse(presenter.canDelete())

        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .parent)
        Page.make(from: .make(
            editing_roles: "teachers",
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertFalse(presenter.canEdit())
    }

    func testCantDeleteFrontPage() {
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .teacher)
        Page.make(from: .make(
            front_page: true,
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertFalse(presenter.canDelete())
    }

    func testCanDeleteNonFrontPage() {
        presenter = PageDetailsPresenter(env: environment, viewController: self, context: context, pageURL: pageURL, app: .teacher)
        Page.make(from: .make(
            front_page: false,
            html_url: htmlURL,
            url: pageURL
        ))
        XCTAssertTrue(presenter.canDelete())
    }

    func testUpdatesThePageOnEdit() {
        Page.make(from: .make(
            body: "Test",
            editing_roles: "",
            html_url: htmlURL,
            title: "Title",
            url: pageURL
        ))
        presenter.viewIsReady()
        XCTAssertEqual(presenter.page?.body, "Test")
        XCTAssertEqual(presenter.page?.title, "Title")

        let updated = APIPage.make(
           body: "Changed",
           html_url: htmlURL,
           title: "Changed",
           url: "changed"
        )

        NotificationCenter.default.post(name: NSNotification.Name("page-edit"), object: nil, userInfo: apiPageToDictionary(page: updated))

        XCTAssertEqual(presenter.page?.body, "Changed")
        XCTAssertEqual(presenter.page?.title, "Changed")
        XCTAssertEqual(presenter.page?.url, "changed")
    }

    func testUpdatesFrontPageWhenChanged() {
        Page.make(from: .make(
            front_page: true,
            html_url: URL(string: "/courses/1/pages/front-page")!,
            page_id: "1234"
        ))
        Page.make(from: .make(
            front_page: false,
            html_url: htmlURL,
            url: pageURL
        ))
        presenter.viewIsReady()

        let updated = APIPage.make(
            front_page: true,
            html_url: htmlURL,
            url: pageURL
        )

        NotificationCenter.default.post(name: NSNotification.Name("page-edit"), object: nil, userInfo: apiPageToDictionary(page: updated))

        let frontPage: [Page] = databaseClient.fetch(NSPredicate(format: "%K == true", #keyPath(Page.isFrontPage)), sortDescriptors: nil)
        XCTAssertEqual(frontPage.count, 1)
        XCTAssertEqual(frontPage.first?.url, pageURL)
    }

    func testDeletePageWithError() {
        Page.make(from: .make(
            html_url: htmlURL,
            url: pageURL
        ))
        let request = DeletePageRequest(context: context, url: pageURL)
        api.mock(request, error: NSError(domain: "domain", code: 1234, userInfo: nil))

        presenter.deletePage()

        wait(for: [errorExpectation], timeout: 1)
        XCTAssertNotNil(resultingError)
    }

    func testDeletePage() {
        let apiPage = APIPage.make(
            html_url: htmlURL,
            url: pageURL
        )
        Page.make(from: apiPage)
        let request = DeletePageRequest(context: context, url: pageURL)
        api.mock(request, value: apiPage)

        let vc = PageDetailsViewController.create(env: environment, context: context, pageURL: pageURL, app: .teacher)
        presenter = PageDetailsPresenter(env: environment, viewController: vc, context: context, pageURL: pageURL, app: .teacher)
        presenter.deletePage()

        wait(for: [router.popExpectation], timeout: 1)

        let page: Page? = databaseClient.fetch().first
        XCTAssertNil(page)
    }

    func apiPageToDictionary(page: APIPage) -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(page)
        return try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
    }
}

extension PageDetailsPresenterTests: PageDetailsViewProtocol {
    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        dismissExpectation.fulfill()
    }

    public func update() {
        updateExpectation.fulfill()
    }

    public func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingSubtitle = subtitle
        resultingColor = color
        navExpectation.fulfill()
    }

    public func showAlert(title: String?, message: String?) {

    }

    public func showError(_ error: Error) {
        resultingError = error
        errorExpectation.fulfill()
    }
}
