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
import XCTest

final class CoreWebViewThemeSwitcherTests: CoreTestCase {

    private var host: UIView!
    private var parent: UIView!
    private var testee: CoreWebViewThemeSwitcherLive!

    override func setUp() {
        super.setUp()
        host = .init()
        parent = .init()
        testee = .init(host: host)

        parent.addSubview(host)
        testee.pinHostAndButton(inside: parent)
    }

    override func tearDown() {
        host = nil
        parent = nil
        testee = nil
        super.tearDown()
    }

    func testCurrentHeight() {
        testee.updateUserInterfaceStyle(with: .light)
        XCTAssertEqual(testee.currentHeight, 0)

        testee.updateUserInterfaceStyle(with: .dark)
        XCTAssertEqual(testee.currentHeight > 0, true)
    }

    func testIsThemeInverted() {
        XCTAssertEqual(testee.isThemeInverted, false)

        triggerButtonTap()
        XCTAssertEqual(testee.isThemeInverted, true)

        triggerButtonTap()
        XCTAssertEqual(testee.isThemeInverted, false)
    }

    // MARK: - Button Tap

    func testButtonTapShouldInvertTheme() {
        testee.updateUserInterfaceStyle(with: .dark)
        let button = findThemeSwitcherButton()
        let darkModeTitle = button.configuration?.title

        // default state: dark
        XCTAssertEqual(button.configuration?.title == darkModeTitle, true)
        XCTAssertEqual(testee.isThemeInverted, false)
        XCTAssertEqual(host?.overrideUserInterfaceStyle, .dark)

        // invert to light state
        triggerButtonTap()
        XCTAssertEqual(button.configuration?.title != darkModeTitle, true)
        XCTAssertEqual(testee.isThemeInverted, true)
        XCTAssertEqual(host?.overrideUserInterfaceStyle, .light)

        // invert to dark state
        triggerButtonTap()
        XCTAssertEqual(button.configuration?.title == darkModeTitle, true)
        XCTAssertEqual(testee.isThemeInverted, false)
        XCTAssertEqual(host?.overrideUserInterfaceStyle, .dark)
    }

    func testButtonTapShouldNotToggleButtonVisibility() {
        let button = findThemeSwitcherButton()
        XCTAssertEqual(button.isHidden, false)

        triggerButtonTap()
        XCTAssertEqual(button.isHidden, false)

        triggerButtonTap()
        XCTAssertEqual(button.isHidden, false)
    }

    // MARK: - Update Style

    func testUpdateStyleShouldNotInvertTheme() {
        XCTAssertEqual(testee.isThemeInverted, false)

        testee.updateUserInterfaceStyle(with: .light)
        XCTAssertEqual(testee.isThemeInverted, false)

        testee.updateUserInterfaceStyle(with: .dark)
        XCTAssertEqual(testee.isThemeInverted, false)
    }

    func testUpdateStyleShouldToggleButtonVisibility() {
        let button = findThemeSwitcherButton()
        XCTAssertEqual(button.isHidden, false)

        testee.updateUserInterfaceStyle(with: .light)
        XCTAssertEqual(button.isHidden, true)

        testee.updateUserInterfaceStyle(with: .dark)
        XCTAssertEqual(button.isHidden, false)
    }

    func testUpdateStyleShouldUpdateParentBackgroundColor() {
        testee.updateUserInterfaceStyle(with: .light)
        XCTAssertEqual(parent.backgroundColor, .backgroundLightest.variantForLightMode)

        testee.updateUserInterfaceStyle(with: .dark)
        XCTAssertEqual(parent.backgroundColor, .backgroundLightest.variantForDarkMode)
    }

    func testUpdateStyleToDarkShouldApplyInvertedState() {
        testee.updateUserInterfaceStyle(with: .dark)

        triggerButtonTap()
        XCTAssertEqual(host.overrideUserInterfaceStyle, .light)

        triggerButtonTap()
        XCTAssertEqual(host.overrideUserInterfaceStyle, .dark)
    }

    func testUpdateStyleToLightShouldNotApplyInvertedState() {
        testee.updateUserInterfaceStyle(with: .light)

        triggerButtonTap()
        XCTAssertEqual(host.overrideUserInterfaceStyle, .light)

        triggerButtonTap()
        XCTAssertEqual(host.overrideUserInterfaceStyle, .light)
    }

    // MARK: - Observation

    func testObservationShouldBeDisabledInitially() {
        triggerStyleDidChangeNotificiation(to: .light)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .unspecified)

        triggerStyleDidChangeNotificiation(to: .dark)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .unspecified)
    }

    func testObservationShouldBeEnabledAfterUpdateStyle() {
        testee.updateUserInterfaceStyle(with: .dark)

        triggerStyleDidChangeNotificiation(to: .light)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .light)

        triggerStyleDidChangeNotificiation(to: .dark)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .dark)
    }
}

private extension CoreWebViewThemeSwitcherTests {
    func findThemeSwitcherButton() -> CoreWebViewThemeSwitcherButton {
        let firstButton = parent.subviews.first { $0 is CoreWebViewThemeSwitcherButton }
        guard let button = firstButton as? CoreWebViewThemeSwitcherButton else {
            XCTFail("Button not found")
            return .init(primaryAction: {})
        }

        return button
    }

    func triggerButtonTap() {
        let button = findThemeSwitcherButton()
        button.sendActions(for: .primaryActionTriggered)
        button.updateConfiguration()
    }

    func triggerStyleDidChangeNotificiation(to style: UIUserInterfaceStyle) {
        NotificationCenter.default.post(
            name: .windowUserInterfaceStyleDidChange,
            object: nil,
            userInfo: ["style": style]
        )
    }
}
