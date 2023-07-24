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

import Core

class TeacherSyllabusTabViewController: SyllabusTabViewController {

    var context: Context?

    override var screenViewTrackingParameters: ScreenViewTrackingParameters {
        get {
            _screenViewTrackingParameters
        }
        set {
            _screenViewTrackingParameters = newValue
        }
    }
    private lazy var _screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context?.pathComponent ?? "")/syllabus/edit"
    )

    lazy var permissions = env.subscribe(GetContextPermissions(context: .course(courseID), permissions: [.manageContent, .manageCourseContentEdit])) { [weak self] in
        self?.updateNavBar()
    }

    lazy var editButton = UIBarButtonItem(
        title: NSLocalizedString("Edit", bundle: .core, comment: ""), style: .plain,
        target: self, action: #selector(edit)
    )

    public class func create(context: Context?, courseID: String) -> TeacherSyllabusTabViewController {
        let controller = TeacherSyllabusTabViewController(nibName: nil, bundle: nil)
        controller.context = context
        controller.courseID = courseID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        permissions.refresh()
    }

    func updateNavBar() {
        guard permissions.first?.manageContent == true || permissions.first?.manageCourseContentEdit == true else { return }
        editButton.accessibilityIdentifier = "Syllabus.editButton"
        navigationItem.rightBarButtonItem = editButton
    }

    @objc func edit() {
        env.router.route(
            to: "\(context?.pathComponent ?? "")/syllabus/edit", from: self, options: .modal(isDismissable: false, embedInNav: true))
    }
}
