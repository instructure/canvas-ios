//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import XCTest
import SwiftUI

class CoreWebViewContentErrorViewEmbedTests: XCTestCase {
    private let view = UIView()

    override func setUp() {
        super.setUp()
        view.subviews.forEach { $0.removeFromSuperview() }
    }

    func testNotEmbedsIfNoDelegateIsPassed() {
        CoreWebViewContentErrorViewEmbed.embed(errorDelegate: nil)
        XCTAssertTrue(view.subviews.isEmpty)
    }

    func testEmbed() {
        let mockDelegate = MockErrorDelegate(mockedView: view)

        // WHEN
        CoreWebViewContentErrorViewEmbed.embed(errorDelegate: mockDelegate)

        // THEN
        guard let errorView = view.subviews.first as? _UIHostingView<CoreHostingBaseView<CoreWebViewContentErrorView>> else {
            return XCTFail()
        }
        XCTAssertTrue(errorView.accessibilityViewIsModal)
    }
}

private class MockErrorDelegate: CoreWebViewErrorDelegate {
    var mockedURL: URL?
    let mockedView: UIView

    init(mockedView: UIView) {
        self.mockedView = mockedView
    }

    func containerForContentErrorView() -> UIView {
        mockedView
    }

    func urlForExternalBrowser() -> URL? {
        mockedURL
    }
}
