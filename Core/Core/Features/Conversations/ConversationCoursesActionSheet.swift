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
import CoreData

public protocol ConversationCoursesActionSheetDelegate: AnyObject {
    func courseSelected(course: Course, user: User)
}

public class ConversationCoursesActionSheet: UIViewController, ErrorViewController {
    let env: AppEnvironment = .shared
    weak var delegate: ConversationCoursesActionSheetDelegate?
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let tableView = UITableView()

    lazy var enrollments = env.subscribe(GetConversationCourses()) { [weak self] in
        self?.update()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public static func create(delegate: ConversationCoursesActionSheetDelegate) -> ConversationCoursesActionSheet {
        let controller = ConversationCoursesActionSheet()
        controller.delegate = delegate
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.transitioningDelegate = BottomSheetTransitioningDelegate.shared
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        view.frame.size.height = 294

        let titleLabel = UILabel()
        titleLabel.text = String(localized: "Choose a course to message", bundle: .core)
        titleLabel.textColor = .textDark
        titleLabel.font = .scaledNamedFont(.semibold14)
        view.addSubview(titleLabel)
        titleLabel.pin(inside: view, leading: 16, trailing: 16, top: 20, bottom: nil)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.registerCell(SubtitleTableViewCell.self)
        view.addSubview(tableView)
        tableView.pin(inside: view, top: nil)
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true

        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        loadingIndicator.startAnimating()

        enrollments.exhaust()
    }

    func update() {
        if !enrollments.pending {
            loadingIndicator.stopAnimating()
        }

        if let error = enrollments.error {
            showError(error)
        }

        tableView.reloadData()
    }
}

extension ConversationCoursesActionSheet: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrollments.pending ? 0 : enrollments.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let enrollment = enrollments[indexPath.row]
        let cell: SubtitleTableViewCell = tableView.dequeue(for: indexPath)
        cell.textLabel?.text = enrollment?.course?.name
        let userName = enrollment?.observedUser.flatMap { User.displayName($0.shortName, pronouns: $0.pronouns) } ?? ""
        cell.detailTextLabel?.text = String.localizedStringWithFormat(String(localized: "for %@", bundle: .core), userName)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let enrollment = enrollments[indexPath.row], let course = enrollment.course, let observedUser = enrollment.observedUser else {
            return
        }

        env.router.dismiss(self) { [weak self] in
            self?.delegate?.courseSelected(course: course, user: observedUser)
        }
    }
}
