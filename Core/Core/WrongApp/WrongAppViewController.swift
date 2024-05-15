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

public class WrongAppViewController: UIViewController {
    weak var delegate: LoginDelegate?

    @IBOutlet var messageTitle: UILabel?
    @IBOutlet var messageDescription: UILabel?
    @IBOutlet var parentButton: WrongAppLinkView?
    @IBOutlet var studentButton: WrongAppLinkView?
    @IBOutlet var teacherButton: WrongAppLinkView?
    @IBOutlet var loginButton: UIButton?
    @IBOutlet var canvasGuidesButton: UIButton?

    public static func create(delegate: LoginDelegate?) -> WrongAppViewController {
        let controller = loadFromStoryboard()
        controller.delegate = delegate
        return controller
    }

    public override func viewDidLoad() {
        view.backgroundColor = .backgroundLightest
        navigationController?.setNavigationBarHidden(true, animated: false)
        messageTitle?.text = String(localized: "Whoops!", bundle: .core)
        messageDescription?.text = String.localizedStringWithFormat(
            String(localized: "It looks like you aren’t enrolled in any courses as %@. One of our other apps might be a better fit. Tap one to visit the App Store.", bundle: .core), (
            Bundle.main.isParentApp ? String(localized: "a parent", bundle: .core, comment: "Embedded in 'enrolled in any courses as %@'") :
            Bundle.main.isTeacherApp ? String(localized: "a teacher", bundle: .core, comment: "Embedded in 'enrolled in any courses as %@'") :
            String(localized: "a student", bundle: .core, comment: "Embedded in 'enrolled in any courses as %@'")
        ))

        loginButton?.setTitle(String(localized: "Log In Again", bundle: .core).localizedUppercase, for: .normal)
        canvasGuidesButton?.setTitle(String(localized: "Canvas Guides", bundle: .core).localizedUppercase, for: .normal)
        canvasGuidesButton?.isHidden = !Bundle.main.isParentApp

        parentButton?.isHidden = Bundle.main.isParentApp
        parentButton?.accessibilityLabel = String(localized: "Canvas Parent", bundle: .core)

        studentButton?.isHidden = Bundle.main.isStudentApp
        studentButton?.accessibilityLabel = String(localized: "Degrees edX", bundle: .core)

        teacherButton?.isHidden = Bundle.main.isTeacherApp
        teacherButton?.accessibilityLabel = String(localized: "Canvas Teacher", bundle: .core)
    }

    @IBAction func loginAgainButtonPressed(_ sender: UIButton) {
        guard let entry = AppEnvironment.shared.currentSession else { return }
        delegate?.userDidLogout(session: entry)
    }

    @IBAction func canvasGuidesButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: "https://community.canvaslms.com/docs/DOC-9919") else {
            return
        }
        delegate?.openExternalURL(url)
    }

    @IBAction func parentPressed() {
        guard let url = URL(string: "https://itunes.apple.com/us/app/canvas-parent/id1097996698?ls=1&mt=8") else { return }
        delegate?.openExternalURL(url)
    }

    @IBAction func studentPressed() {
        guard let url = URL(string: "https://itunes.apple.com/us/app/canvas-student/id480883488?ls=1&mt=8") else { return }
        delegate?.openExternalURL(url)
    }

    @IBAction func teacherPressed() {
        guard let url = URL(string: "https://itunes.apple.com/us/app/canvas-teacher/id1257834464?ls=1&mt=8") else { return }
        delegate?.openExternalURL(url)
    }
}
