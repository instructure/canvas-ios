//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import XCTest

<<<<<<<< HEAD:Horizon/Horizon/Sources/Features/Notebook/Common/View/HighlightWebView/EnableZoom.swift
private class EnableZoom: CoreWebViewFeature {
    private let script: String =
    """
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
        document.getElementsByTagName('head')[0].appendChild(meta);
    """

    override func apply(on webView: CoreWebView) {
        webView.addScript(script)
    }
}

extension CoreWebViewFeature {
    static var enableZoom: CoreWebViewFeature {
        EnableZoom()
========
class CoreSwitchTests: XCTestCase {
    private var switchToggledByUser = false

    override func setUp() {
        super.setUp()
        switchToggledByUser = false
    }

    func test_sendsNoValueChangedAction_whenStateUpdatedProgramatically() {
        let testee = CoreSwitch()
        testee.addTarget(self, action: #selector(didToggleSwitch), for: .valueChanged)

        // WHEN
        testee.isOn = true
        testee.isOn = false

        // THEN
        XCTAssertEqual(switchToggledByUser, false)
    }

    @objc
    private func didToggleSwitch() {
        switchToggledByUser = true
>>>>>>>> origin/master:Core/CoreTests/Common/CommonUI/UIViews/CoreSwitchTests.swift
    }
}
