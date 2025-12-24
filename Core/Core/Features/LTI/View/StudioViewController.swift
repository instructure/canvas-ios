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

import UIKit

struct StudioPage {
    let title: String?
    let url: URL

    init(title: String? = nil, url: URL) {
        self.title = title
        self.url = url
    }
}

class StudioViewController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    convenience init(url: URL) {
        self.init(page: StudioPage(title: nil, url: url))
    }

    public init(page: StudioPage) {
        let controller = CoreWebViewController(studioEnhancementsEnabled: false)
        controller.webView.load(URLRequest(url: page.url))
        controller.addDoneButton()
        controller.title = page.title
            ?? page.url.queryValue(for: "title")?.removingPercentEncoding
            ?? String(localized: "Studio", bundle: .core)

        super.init(rootViewController: controller)

        navigationBar.useModalStyle(forcedTheme: .light)
        modalPresentationCapturesStatusBarAppearance = true
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest.variantForLightMode
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
