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

public struct APITermsOfService: Codable, Equatable {
    let content: String
}

// https://canvas.instructure.com/doc/api/all_resources.html#method.accounts.terms_of_services
struct APITermsOfServiceRequestable: APIRequestable {
    typealias Response = APITermsOfService

    var path: String {
        return "accounts/self/terms_of_service"
    }
}

public class TermsOfServiceViewController: UIViewController {
    var env: AppEnvironment
    var webView: CoreWebView?

    public init(_ env: AppEnvironment = .shared) {
        self.env = env
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        self.addDoneButton()

        self.title = NSLocalizedString("Terms of Use", bundle: .core, comment: "")

        let web = CoreWebView()
        self.view.addSubview(web)
        web.pin(inside: self.view)
        self.webView = web

        self.loadTerms()
    }

    func loadTerms() {
        let request = APITermsOfServiceRequestable()
        self.env.api.makeRequest(request) { [weak self] (response, _, error) in
            DispatchQueue.main.async {
                guard error == nil, let response = response else {
                    self?.showErrorMessage()
                    return
                }
                self?.webView?.loadHTMLString(response.content)
            }
        }
    }

    func showErrorMessage() {
        let label = DynamicLabel(frame: self.view.frame)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = NSLocalizedString("There was a problem retrieving the Terms of Use.", bundle: .core, comment: "")
        self.view.addSubview(label)
    }
}
