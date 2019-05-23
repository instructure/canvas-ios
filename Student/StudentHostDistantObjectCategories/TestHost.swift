//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import UIKit
@testable import Core
@testable import Student

// https://github.com/google/EarlGrey/blob/earlgrey2/docs/swift-white-boxing.md

@objc
protocol TestHost {
    func reset()
    func logIn(domain: String, token: String)
    func show(_ route: String)
    func mockData(_ data: Data)
    func mockDownload(_ data: Data)
    func grey_getLabel(_ elementData: ElementData) -> GREYActionBlock
    func grey_getId(_ elementData: ElementData) -> GREYActionBlock
    func grey_getClassName(_ elementData: ElementData) -> GREYActionBlock
    func grey_getText(_ elementData: ElementData) -> GREYActionBlock
}

@objc
protocol ElementData {
    var label: String { get set }
    var id: String { get set }
    var className: String { get set }
    var text: String { get set }
}

extension GREYHostApplicationDistantObject: TestHost {
    var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("wrong app delegate type")
        }
        return delegate
    }

    func reset() {
        appDelegate.window!.layer.speed = 100
        resetNavigationStack()
        resetDatabase()
        setScreenshotDir()
        MockURLSession.reset()
    }

    private func resetNavigationStack() {
        guard let root = appDelegate.window!.rootViewController else { return }
        removePresented(root)
        let navController = root as? UINavigationController ?? root.navigationController
        navController?.popToRootViewController(animated: false)
    }

    private func removePresented(_ controller: UIViewController) {
        if let presented = controller.presentedViewController {
            removePresented(presented)
            presented.dismiss(animated: false, completion: nil)
        }
    }

    private func resetDatabase() {
        do {
            let store = appDelegate.environment.database
            try store.clearAllRecords()
        } catch {
            fatalError("failed to reset database")
        }
    }

    func logIn(domain: String, token: String) {
        let baseURL = URL(string: "https://\(domain)")!
        appDelegate.setup(session: KeychainEntry(accessToken: token, baseURL: baseURL, expiresAt: nil, locale: "en", refreshToken: nil, userID: "", userName: ""))
    }

    func show(_ route: String) {
        guard var controller = router.match(.parse(route)) else {
            fatalError("No route for \(route)")
        }
        if !(controller is UINavigationController) {
            controller = UINavigationController(rootViewController: controller)
        }
        appDelegate.window!.rootViewController = controller
        controller.loadViewIfNeeded()
    }

    func setScreenshotDir() {
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("no document directory")
        }

        let screenshotDir = documentDir.appendingPathComponent("earlgrey_screenshots").path

        do {
            try FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }

        GREYConfiguration.shared.setValue(screenshotDir, forConfigKey: GREYConfigKey.artifactsDirLocation)
    }

    func mockData(_ data: Data) {
        MockURLSession.mockData(data)
    }

    func mockDownload(_ data: Data) {
        MockURLSession.mockDownload(data)
    }

    func grey_getLabel(_ elementData: ElementData) -> GREYActionBlock {
        return GREYActionBlock.action(withName: "grey_getLabel") { element, _ -> Bool in
            let elementObject = element as? NSObject
            elementData.label = elementObject?.accessibilityLabel ?? ""
            return true
        }
    }

    func grey_getId(_ elementData: ElementData) -> GREYActionBlock {
        return GREYActionBlock.action(withName: "grey_getId") { element, _ -> Bool in
            let elementObject = element as? UIAccessibilityIdentification
            elementData.id = elementObject?.accessibilityIdentifier ?? ""
            return true
        }
    }

    func grey_getClassName(_ elementData: ElementData) -> GREYActionBlock {
        return GREYActionBlock.action(withName: "grey_getClassName") { element, _ -> Bool in
            elementData.className = String(describing: element.self)
            return true
        }
    }

    func grey_getText(_ elementData: ElementData) -> GREYActionBlock {
        return GREYActionBlock.action(
            withName: "grey_getText") { element, _ -> Bool in
            let elementObject = element as? NSObject
            let text = elementObject?.perform(#selector(getter: UILabel.text),
                                              with: nil)?.takeRetainedValue() as? String
            elementData.text = text ?? ""
            return true
        }
    }
}
