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

class StudioViewController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    public init(url: URL) {
        let controller = CoreWebViewController()
        controller.webView.load(URLRequest(url: url))
        controller.addDoneButton()
        controller.title = String(localized: "Studio", bundle: .core)

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
