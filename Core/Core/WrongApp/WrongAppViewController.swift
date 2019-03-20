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

import UIKit

public enum AppName: String {
    case student, teacher, parent

    var title: String {
        switch self {
        case .parent:
            return NSLocalizedString("Not a parent?", bundle: .core, comment: "")
        case .student:
            return NSLocalizedString("Not a student?", bundle: .core, comment: "")
        case .teacher:
            return NSLocalizedString("Not a teacher?", bundle: .core, comment: "")
        }
    }

    var description: String {
        switch self {
        case .parent:
            // swiftlint:disable:next line_length
            return NSLocalizedString("You need at least one active observer enrollment to use Canvas Parent. If you're a student or teacher, try one of our other apps below.", bundle: .core, comment: "")
        default:
            return NSLocalizedString("One of our other apps might be a better fit. Tap one to visit the App Store.", bundle: .core, comment: "")
        }
    }

    var image: UIImage? {
        switch self {
        case .parent:
            return UIImage(named: "Canvas-Parent", in: .core, compatibleWith: nil)
        case .student:
            return UIImage(named: "Canvas-Student", in: .core, compatibleWith: nil)
        case .teacher:
            return UIImage(named: "Canvas-Teacher", in: .core, compatibleWith: nil)
        }
    }

    var url: URL? {
        switch self {
        case .parent:
            return URL(string: "https://itunes.apple.com/us/app/canvas-parent/id1097996698?ls=1&mt=8")
        case .student:
            return URL(string: "https://itunes.apple.com/us/app/canvas-by-instructure/id480883488?ls=1&mt=8")
        case .teacher:
            return URL(string: "https://itunes.apple.com/us/app/canvas-teacher/id1257834464?ls=1&mt=8")
        }
    }

    func appsToShow() -> [AppName] {
        switch self {
        case .parent:
            return [.student, .teacher]
        case .student:
            return [.teacher, .parent]
        case .teacher:
            return [.student, .parent]
        }
    }
}

public protocol WrongAppViewControllerDelegate: class {
    func loginAgainPressed()
    func openURL(_: URL)
}

public class WrongAppViewController: UIViewController {
    var app: AppName?
    weak var delegate: WrongAppViewControllerDelegate?

    @IBOutlet var messageTitle: UILabel!
    @IBOutlet var messageDescription: UILabel!
    @IBOutlet var firstAppButton: UIButton!
    @IBOutlet var secondAppButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var canvasGuidesButton: UIButton!

    public static func create(app: AppName, delegate: WrongAppViewControllerDelegate) -> WrongAppViewController {
        let controller = self.loadFromStoryboard()
        controller.app = app
        controller.delegate = delegate
        return controller
    }

    public override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        messageTitle.text = app?.title
        messageDescription.text = app?.description

        loginButton.titleLabel?.text = NSLocalizedString("Log In Again", bundle: .core, comment: "")
        canvasGuidesButton.titleLabel?.text = NSLocalizedString("Canvas Guides", bundle: .core, comment: "")
        canvasGuidesButton.isHidden = app != .parent

        let appsToShow = app?.appsToShow()
        if let firstApp = appsToShow?.first {
            firstAppButton.setImage(firstApp.image, for: .normal)
        }
        if let secondApp = appsToShow?.last {
            secondAppButton.setImage(secondApp.image, for: .normal)
        }
    }

    @IBAction func loginAgainButtonPressed(_ sender: UIButton) {
        delegate?.loginAgainPressed()
    }

    @IBAction func canvasGuidesButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: "https://community.canvaslms.com/docs/DOC-9919") else {
            return
        }
        delegate?.openURL(url)
    }

    @IBAction func firstButtonPressed(_ sender: UIButton) {
        guard let url = app?.appsToShow().first?.url else {
            return
        }
        delegate?.openURL(url)
    }

    @IBAction func secondButtonPressed(_ sender: UIButton) {
        guard let url = app?.appsToShow().last?.url else {
            return
        }
        delegate?.openURL(url)
    }
}
