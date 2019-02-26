//
// Copyright (C) 2019-present Instructure, Inc.
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

import Core
import UIKit
import CanvasCore

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

class TermsOfServiceViewController: UIViewController {
    var env: AppEnvironment
    var webView: CanvasWebView?

    init(_ env: AppEnvironment = .shared) {
        self.env = env
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.addDoneButton()

        self.title = NSLocalizedString("Terms of Use", bundle: .parent, comment: "")

        let web = CanvasWebView()
        self.view.addSubview(web)
        web.pinToAllSides(ofView: self.view)
        self.webView = web

        self.loadTerms()
    }

    func loadTerms() {
        let request = APITermsOfServiceRequestable()
        self.env.api.makeRequest(request) { [weak self] (response, nil, error) in
            DispatchQueue.main.async {
                guard error == nil, let response = response else {
                    self?.showErrorMessage()
                    return
                }

                self?.webView?.load(source: .html(title: NSLocalizedString("Terms of Use", bundle: .parent, comment: ""), body: response.content, baseURL: nil))
            }
        }
    }

    func showErrorMessage() {
        let label = DynamicLabel(frame: self.view.frame)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = NSLocalizedString("There was a problem retrieving the Terms of Use.", bundle: .parent, comment: "")
        self.view.addSubview(label)
    }
}
