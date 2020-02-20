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

public class SyllabusViewController: UIViewController {

    @IBOutlet weak var webView: CoreWebView!
    var presenter: SyllabusPresenter!

    public static func create(courseID: String) -> SyllabusViewController {
        let vc = loadFromStoryboard()
        vc.presenter = SyllabusPresenter(view: vc, courseID: courseID)
        return vc
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.linkDelegate = self
        webView.backgroundColor = .named(.backgroundLightest)
        presenter.viewIsReady()
    }
}

extension SyllabusViewController: SyllabusViewProtocol {
    func loadHtml(_ html: String?) {
        guard let html = html else { return }
        webView?.loadHTMLString(html, baseURL: nil)
    }
}

extension SyllabusViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        presenter.show(url, from: self)
        return true
    }
}
