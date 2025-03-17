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

import UIKit

public class LTIViewController: UIViewController, ErrorViewController, ColoredNavViewProtocol {
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!

    private var env: AppEnvironment = .defaultValue
    public var tools: LTITools!
    public var name: String?
    public var color: UIColor?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }

    lazy var courses = courseID.flatMap { env.subscribe(GetCourse(courseID: $0, include: [])) { [weak self] in
        self?.updateNavBar()
    }}

    var courseID: String? {
        guard tools.context.contextType == .course else { return nil }
        return tools.context.id
    }

    public static func create(env: AppEnvironment, tools: LTITools, name: String? = nil) -> Self {
        let controller = loadFromStoryboard()
        controller.tools = tools
        controller.name = name
        controller.env = env
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        spinnerView.isHidden = true
        nameLabel.text = name ?? String(localized: "LTI Tool", bundle: .core)
        setupTitleViewInNavbar(title: String(localized: "External Tool", bundle: .core))
        if name == nil {
            // try to get a more descriptive name of the tool
            tools.getSessionlessLaunch { [weak self] response in
                performUIUpdate {
                    self?.nameLabel.text = response?.name ?? self?.nameLabel.text
                }
            }
        }
        let isQuizLTI = tools.isQuizLTI ?? false
        descriptionLabel.text = isQuizLTI
            ? String(localized: "This quiz opens in a web browser. Select \"Open the Quiz\" to proceed.", bundle: .core)
            : String(localized: "This page can only be viewed from a web browser.", bundle: .core)
        let openButtonTitle = isQuizLTI
            ? String(localized: "Open the Quiz", bundle: .core)
            : String(localized: "Open in Safari", bundle: .core)
        openButton.setTitle(openButtonTitle, for: .normal)
        colors.refresh()
        courses?.refresh()
    }

    func updateNavBar() {
        guard env.app != .horizon else {
            return
        }
        let course = courses?.first
        updateNavBar(subtitle: course?.name, color: course?.color)
    }

    @IBAction func openButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        spinnerView.isHidden = false
        tools.presentTool(from: self, animated: true) { [weak self, weak sender] success in
            performUIUpdate {
                self?.spinnerView.isHidden = true
                sender?.isEnabled = true
                if !success {
                    self?.showError(message: String(localized: "Could not launch tool. Please try again.", bundle: .core))
                }
            }
        }
    }
}
