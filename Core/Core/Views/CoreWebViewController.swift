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

import UIKit

public class CoreWebViewController: UIViewController {
    public let webView = CoreWebView()

    public init(env: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        webView.navigation = .deepLink { [weak self] (url: URL) -> Bool? in
            guard let self = self else { return false }
            env.router.route(to: url, from: self, options: nil)
            return true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = webView
    }
}
