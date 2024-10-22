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

import XCTest
import Combine
import SwiftUI
import TestsFoundation
@testable import Core

class CoreSearchHostingControllerTests: CoreTestCase {

    private func setupTestSearch(enabled: Bool = true) -> CoreSearchHostingController<TestSearchInfo, TestSearchDescriptor, TestContentView> {
        let descriptor = TestSearchDescriptor()
        let controller = CoreSearchHostingController(
            router: router,
            info: TestSearchInfo(),
            descriptor: descriptor,
            content: TestContentView()
        )

        let navigation = UINavigationController(rootViewController: controller)

        environment.window?.rootViewController = navigation
        drainMainQueue(thoroughness: 20)

        descriptor.enabled.send(enabled)

        return controller
    }

    func test_enablement() throws {
        let controller = setupTestSearch(enabled: false)
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)

        controller.searchDescriptor.enabled.send(true)
        XCTAssertNotNil(controller.navigationItem.rightBarButtonItem)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "search_bar_button")
    }

    func test_show_hide() throws {
        // Given
        let controller = setupTestSearch()
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "search_bar_button")

        // When - Show
        controller.navigationItem.rightBarButtonItem?.primaryAction?.trigger()
        drainMainQueue(thoroughness: 20)

        // Then
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "filter_bar_button")
        XCTAssertEqual(controller.navigationItem.leftBarButtonItem?.accessibilityIdentifier, "close_bar_button")
        XCTAssertNotNil(controller.navigationItem.titleView?.findSubview(accessID: "ui_search_field"))

        // When - Hide
        controller.navigationItem.leftBarButtonItem?.primaryAction?.trigger()
        // Then
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "search_bar_button")
        XCTAssertNil(controller.navigationItem.titleView)
    }

    func test_search_experience_started() throws {
        // Given
        let controller = setupTestSearch()
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "search_bar_button")

        // When - Show
        controller.navigationItem.rightBarButtonItem?.primaryAction?.trigger()
        drainMainQueue(thoroughness: 20)

        // When - Type
        let textField: UITextField = try XCTUnwrap(controller.navigationItem.titleView?.findSubview(accessID: "ui_search_field"))
        textField.text = "Example"
        _ = textField.delegate?.textFieldShouldReturn?(textField)

        XCTAssertEqual(controller.searchContext.searchText.value, "Example")

        let searchResultsVC = router.lastViewController as? CoreSplitViewController
        XCTAssertNotNil(searchResultsVC)
    }

    func test_filter_called() throws {
        // Given
        let controller = setupTestSearch()
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "search_bar_button")

        // When - Show search
        controller.navigationItem.rightBarButtonItem?.primaryAction?.trigger()
        drainMainQueue(thoroughness: 20)

        // When - Tap on filter button
        controller.navigationItem.rightBarButtonItem?.primaryAction?.trigger()
        drainMainQueue(thoroughness: 20)

        // Presented
        let searchResultsVC = try XCTUnwrap(router.presented)
        XCTAssertEqual(searchResultsVC.view.accessibilityIdentifier, "filter_editor_view")
    }
}

// MARK: - Mocks

private class TestSearchDescriptor: SearchDescriptor {
    typealias Filter = Never
    typealias FilterEditor = Text
    typealias Support = NoSearchSupportAction
    typealias Display = Text

    var enabled = CurrentValueSubject<Bool, Never>(false)
    var enabledPublished: AnyPublisher<Bool, Never> {
        enabled.eraseToAnyPublisher()
    }

    var support: Core.SearchSupportOption<Core.NoSearchSupportAction>?

    func searchDisplayView(_ filter: Binding<Never?>) -> Text {
        Text("Search Display")
    }

    func filterEditorView(_ filter: Binding<Never?>) -> Text {
        Text("Filter Editor")
    }
}

private struct TestContentView: View {
    var body: some View {
        Text("Content")
    }
}

private struct TestSearchInfo: SearchContextInfo {
    static var environmentKeyPath: EnvironmentKeyPath { \.testSearchContext }
    static var defaultInfo = TestSearchInfo()

    var searchPrompt: String { "Search placeholder" }
    var value: Int = 0
}

private extension EnvironmentValues {
    var testSearchContext: CoreSearchContext<TestSearchInfo> {
        get { self[TestSearchInfo.EnvironmentKey.self] }
        set { self[TestSearchInfo.EnvironmentKey.self] = newValue }
    }
}

// MARK: - Testing Utils

extension UIAction {
    func trigger() { handler(self) }
    var handler: UIActionHandler {
        typealias ActionHandlerBlock = @convention(block) (UIAction) -> Void
        let handler = value(forKey: "handler") as AnyObject
        return unsafeBitCast(handler, to: ActionHandlerBlock.self)
    }
}

extension UIView {

    func findSubview(accessID: String) -> UIView? {
        for subview in subviews {
            if subview.accessibilityIdentifier == accessID {
                return subview
            }
            if let found = subview.findSubview(accessID: accessID) {
                return found
            }
        }
        return nil
    }

    func findSubview<V: UIView>(of type: V.Type = V.self, accessID: String) -> V? {
        for subview in subviews {
            if let found = subview as? V, found.accessibilityIdentifier == accessID {
                return found
            }
            if let found = subview.findSubview(of: type, accessID: accessID) {
                return found
            }
        }
        return nil
    }
}
