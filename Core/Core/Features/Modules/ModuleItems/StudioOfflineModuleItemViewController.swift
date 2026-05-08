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

import UIKit

public final class StudioOfflineModuleItemViewController: UIViewController {
    private let webView = CoreWebView(features: [])
    private let sessionID: String
    private let courseID: String
    private let moduleItemID: String

    public static func create(
        sessionID: String,
        courseID: String,
        moduleItemID: String,
        title: String
    ) -> StudioOfflineModuleItemViewController {
        let vc = StudioOfflineModuleItemViewController(
            sessionID: sessionID,
            courseID: courseID,
            moduleItemID: moduleItemID
        )
        vc.navigationItem.title = title
        vc.title = title
        return vc
    }

    private init(sessionID: String, courseID: String, moduleItemID: String) {
        self.sessionID = sessionID
        self.courseID = courseID
        self.moduleItemID = moduleItemID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        view.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: view)
        loadOfflineContent()
    }

    private func loadOfflineContent() {
        let filePath = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: sessionID,
            courseId: courseID,
            sectionName: OfflineFolderPrefix.studioModuleItems.rawValue,
            resourceId: moduleItemID
        ).appendingPathComponent("body.html")

        webView.loadContent(
            isOffline: true,
            filePath: filePath,
            content: nil,
            originalBaseURL: nil
        )
    }
}
