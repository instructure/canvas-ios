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
import Core

protocol EditComposeRecipientsViewControllerDelegate: class {
    func editRecipientsControllerDidFinish(_ controller: EditComposeRecipientsViewController)
}

class EditComposeRecipientsViewController: UITableViewController {
    var context: Context!
    var observeeID: String?
    var selectedRecipients: Set<APIConversationRecipient> = []
    weak var delegate: EditComposeRecipientsViewControllerDelegate?
    var env: AppEnvironment { .shared }

    lazy var teachers = env.subscribe(GetSearchRecipients(context: context, contextQualifier: .teachers)) { [weak self] in
        self?.update()
    }
    lazy var tas = env.subscribe(GetSearchRecipients(context: context, contextQualifier: .tas)) { [weak self] in
        self?.update()
    }
    lazy var observee = observeeID.flatMap { env.subscribe(GetSearchRecipients(context: context, userID: $0)) { [weak self] in
        self?.update()
    }}

    var recipients: [SearchRecipient] = []

    static func create(context: Context, observeeID: String?, selectedRecipients: Set<APIConversationRecipient>) -> EditComposeRecipientsViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.observeeID = observeeID
        controller.selectedRecipients = selectedRecipients
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Recipients", bundle: .parent, comment: "")
        teachers.exhaust(force: false)
        tas.exhaust(force: false)
        observee?.refresh(force: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.editRecipientsControllerDidFinish(self)
    }

    func update() {
        recipients = (teachers.all ?? []) + (tas.all ?? [])
        if let observee = self.observee?.first {
            recipients.append(observee)
        }
        recipients.sort {
            let tieBreaker = $0.fullName.localizedCompare($0.fullName) == .orderedAscending
            let lhs = [
                $0.hasRole(.teacher, in: context) ? 2 : 0,
                $0.hasRole(.ta, in: context) ? 1 : 0,
            ].reduce(0, +)
            let rhs = [
                $1.hasRole(.teacher, in: context) ? 2 : 0,
                $1.hasRole(.ta, in: context) ? 1 : 0,
            ].reduce(0, +)
            if lhs == rhs {
                return tieBreaker
            }
            return lhs > rhs
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(for: indexPath) as RecipientCell
        let person = recipients[indexPath.row]
        cell.nameLabel.text = person.displayName
        cell.roleLabel.text = person.commonCourses
            .filter { $0.courseID == context.id }
            .compactMap { Role(rawValue: $0.role)?.description() }
            .joined(separator: ", ")
        cell.avatarView.name = person.fullName
        cell.selectedView.isHidden = !selectedRecipients.contains(APIConversationRecipient(searchRecipient: person))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipient = APIConversationRecipient(searchRecipient: recipients[indexPath.row])
        if selectedRecipients.contains(recipient) {
            selectedRecipients.remove(recipient)
        } else {
            selectedRecipients.insert(recipient)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

class RecipientCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: DynamicLabel!
    @IBOutlet weak var roleLabel: DynamicLabel!
    lazy var selectedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.named(.electric).withAlphaComponent(0.8)
        self.contentView.addSubview(view)
        let check = UIImageView(image: UIImage.icon(.check))
        check.tintColor = UIColor.named(.backgroundLightest)
        check.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(check)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            view.heightAnchor.constraint(equalTo: avatarView.heightAnchor),
            view.widthAnchor.constraint(equalTo: avatarView.widthAnchor),
            check.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    func initialize() {
        backgroundColor = .named(.backgroundLightest)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedView.roundCorners(corners: .allCorners, radius: selectedView.frame.size.width / 2)
    }
}
