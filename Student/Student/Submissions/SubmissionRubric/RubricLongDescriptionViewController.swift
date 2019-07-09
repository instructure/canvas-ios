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

import UIKit
import Core

class RubricLongDescriptionViewController: UIViewController {

    let longDescription: String
    weak var delegate: CoreWebViewLinkDelegate?

    init(longDescription: String, title: String) {
        self.longDescription = longDescription
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addDoneButton()

        let webView = CoreWebView()
        webView.linkDelegate = delegate
        webView.loadHTMLString(longDescription)

        self.view.addSubview(webView)
        webView.pin(inside: self.view)
    }
}
