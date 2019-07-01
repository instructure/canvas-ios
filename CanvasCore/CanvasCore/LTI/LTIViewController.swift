//
// Copyright (C) 2017-present Instructure, Inc.
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
import Marshal
import SafariServices

public class LTIViewController: UIViewController {
    @objc public let toolName: String
    @objc public let courseID: String?
    @objc public let launchURL: URL
    @objc public let session: Session
    @objc public let fallbackURL: URL?

    @objc var spinner: UIActivityIndicatorView!
    @objc var button: UIButton!

    @objc public convenience init(toolName: String, courseID: String?, launchURL: URL, in session: Session) {
        self.init(toolName: toolName, courseID: courseID, launchURL: launchURL, in: session, fallbackURL: nil)
    }
    
    @objc public init(toolName: String, courseID: String?, launchURL: URL, in session: Session, fallbackURL: URL? = nil) {
        self.toolName = toolName
        self.courseID = courseID
        self.launchURL = launchURL
        self.session = session
        self.fallbackURL = fallbackURL

        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        button = UIButton(type: .system)
        button.setTitleColor(Brand.current.primaryButtonTextColor, for: .normal)
        button.backgroundColor = Brand.current.primaryButtonColor
        button.setTitle(NSLocalizedString("Launch External Tool", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(launch), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.sizeToFit()
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc func launch() {
        showLoading(true)
        let presentingVC = navigationController ?? self
        ExternalToolManager.shared.launch(launchURL, in: session, from: presentingVC, fallbackURL: fallbackURL) { [weak self] in
            self?.showLoading(false)
        }
    }

    @objc func showLoading(_ loading: Bool) {
        loading ? spinner.startAnimating() : spinner.stopAnimating()
        button.isHidden = loading
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
}
