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

public class TermsOfServiceViewController: UIViewController {
    let env = AppEnvironment.shared
    let webView = CoreWebView()

    public override func viewDidLoad() {
        title = NSLocalizedString("Terms of Use", bundle: .core, comment: "")
        view.backgroundColor = .backgroundLightest
        view.addSubview(webView)
        webView.pin(inside: view)

        env.api.makeRequest(GetAccountTermsOfServiceRequest()) { [weak self] (response, _, error) in performUIUpdate {
            guard error == nil, let content = response?.content else {
                self?.showErrorMessage()
                return
            }
            self?.webView.loadHTMLString(content)
        } }
    }

    func showErrorMessage() {
        let label = UILabel(frame: view.frame)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = NSLocalizedString("There was a problem retrieving the Terms of Use.", bundle: .core, comment: "")
        view.addSubview(label)
    }
}
