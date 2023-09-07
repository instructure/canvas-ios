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
import mobile_offline_downloader_ios

public class LTIViewController: UIViewController, ColoredNavViewProtocol, ErrorViewController {
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!

    let env = AppEnvironment.shared
    public var tools: LTITools!
    public var name: String?
    public var color: UIColor?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    public var moduleItem: ModuleItem?

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

    public static func create(tools: LTITools, name: String? = nil) -> Self {
        let controller = loadFromStoryboard()
        controller.tools = tools
        controller.name = name
        return controller
    }

    public static func create(tools: LTITools, moduleItem: ModuleItem) -> Self {
        let controller = loadFromStoryboard()
        controller.tools = tools
        controller.moduleItem = moduleItem
        controller.title = moduleItem.title
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        spinnerView.isHidden = true
        nameLabel.text = name ?? NSLocalizedString("LTI Tool", bundle: .core, comment: "")
        setupTitleViewInNavbar(title: NSLocalizedString("External Tool", bundle: .core, comment: ""))
        if name == nil {
            // try to get a more descriptive name of the tool
            tools.getSessionlessLaunch { [weak self] response in
                performUIUpdate {
                    self?.nameLabel.text = response?.name ?? self?.nameLabel.text
                }
            }
        }
        colors.refresh()
        courses?.refresh()
    }

    func updateNavBar() {
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
                    self?.showError(message: NSLocalizedString("Could not launch tool. Please try again.", bundle: .core, comment: ""))
                }
            }
        }
    }
}
