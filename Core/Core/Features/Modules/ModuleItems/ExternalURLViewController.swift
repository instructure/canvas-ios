//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
import UIKit
import SafariServices

public class ExternalURLViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet weak var spinnerView: CircleProgressView!

    public var color: UIColor?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    private var env: AppEnvironment = .defaultValue
    public var name: String!
    public var url: URL!
    public var courseID: String?

    public var authenticate = false

    public lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }

    public lazy var courses = courseID.flatMap { env.subscribe(GetCourse(courseID: $0, include: [])) { [weak self] in
        self?.updateNavBar()
    }}

    public static func create(env: AppEnvironment, name: String, url: URL, courseID: String?) -> Self {
        let controller = loadFromStoryboard()
        controller.name = name
        controller.url = url
        controller.env = env
        controller.courseID = courseID
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        nameLabel.text = name
        setupTitleViewInNavbar(title: String(localized: "External URL", bundle: .core))
        colors.refresh()
        courses?.refresh()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    public func updateNavBar() {
        let course = courses?.first
        updateNavBar(subtitle: course?.name, color: course?.color)
    }

    @IBAction public func openButtonPressed(_ sender: UIButton) {
        if authenticate {
            spinnerView.isHidden = false
            env.api.makeRequest(GetWebSessionRequest(to: url)) { [weak self] response, _, _ in
                guard let self = self else { return }
                performUIUpdate {
                    self.spinnerView.isHidden = true
                    self.openInSafari(url: response?.session_url ?? self.url)
                }
            }
            return
        }
        openInSafari(url: url)
    }

    func openInSafari(url: URL) {
        let safari = SFSafariViewController(url: url)
        env.router.show(safari, from: self, options: .modal(.overFullScreen))
    }
}
