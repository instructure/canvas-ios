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

import Core
import WebKit
import XCTest

@available(iOS 16.0, *)
class CoreWebViewFullScreenVideoSupportTests: XCTestCase {

    func testEnterFullScreenMode() {
        let host = UIView(frame: .init(origin: .zero, size: .init(width: 123, height: 321)))
        let webView = MockWebView()
        webView.backgroundColor = .purple
        host.addSubview(webView)
        webView.pinWithThemeSwitchButton(
            inside: host,
            leading: 0,
            trailing: nil,
            top: nil,
            bottom: nil
        )
        let constraint = host.constraintsAffecting(view: webView).first!

        // WHEN
        webView.mockedFullscreenState = .enteringFullscreen

        // THEN
        XCTAssertTrue(webView.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(webView.autoresizingMask, [.flexibleWidth, .flexibleHeight])
        XCTAssertEqual(webView.frame, host.frame)
        XCTAssertEqual(webView.backgroundColor, .black)

        // WHEN
        constraint.isActive = false
        webView.mockedFullscreenState = .notInFullscreen

        // THEN
        XCTAssertFalse(webView.translatesAutoresizingMaskIntoConstraints)
        XCTAssertTrue(constraint.isActive)
        XCTAssertEqual(webView.backgroundColor, .purple)
    }
}

@available(iOS 16.0, *)
class MockWebView: CoreWebView {
    var mockedFullscreenState: FullscreenState? {
        willSet {
            willChangeValue(for: \.fullscreenState)
        }
        didSet {
            didChangeValue(for: \.fullscreenState)
        }
    }

    override var fullscreenState: FullscreenState {
        mockedFullscreenState ?? .enteringFullscreen
    }
}
