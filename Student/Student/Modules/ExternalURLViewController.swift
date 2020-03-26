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
import Core
import UIKit
import SafariServices

class ExternalURLViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var nameLabel: UILabel!

    var color: UIColor?
    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    let env = AppEnvironment.shared
    var name: String!
    var url: URL!
    var courseID: String?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }

    lazy var courses = courseID.flatMap { env.subscribe(GetCourse(courseID: $0, include: [])) { [weak self] in
        self?.updateNavBar()
    }}

    static func create(name: String, url: URL, courseID: String?) -> Self {
        let controller = loadFromStoryboard()
        controller.name = name
        controller.url = url
        controller.courseID = courseID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        nameLabel.text = name
        setupTitleViewInNavbar(title: NSLocalizedString("External URL", bundle: .core, comment: ""))

        colors.refresh()
        courses?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
    }

    func updateNavBar() {
        let course = courses?.first
        updateNavBar(subtitle: course?.name, color: course?.color)
    }

    @IBAction func openButtonPressed(_ sender: UIButton) {
        let safari = SFSafariViewController(url: url)
        env.router.show(safari, from: self, options: .modal(.overFullScreen))
    }
}
