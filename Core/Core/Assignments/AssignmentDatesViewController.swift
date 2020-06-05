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

class AssignmentDatesViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var linesView: UIStackView!

    var assignmentID = ""
    var courseID = ""
    let env = AppEnvironment.shared

    lazy var assignment = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID)) { [weak self] in
        self?.update()
    }

    static func create(courseID: String, assignmentID: String) -> AssignmentDatesViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.assignmentID = assignmentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = nil
        button.accessibilityLabel = NSLocalizedString("View all dates", bundle: .core, comment: "")
        headingLabel.text = NSLocalizedString("Due", bundle: .core, comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assignment.refresh(force: true)
    }

    func update() {
        guard let assignment = assignment.first else { return }
        for view in linesView.arrangedSubviews { view.removeFromSuperview() }
        guard assignment.allDates.count <= 1 else {
            addLabel(text: NSLocalizedString("Multiple Due Dates", bundle: .core, comment: ""))
            return
        }

        let first = assignment.allDates.first

        let dueTitle = NSLocalizedString("Due:", bundle: .core, comment: "")
        if let dueAt = assignment.dueAt ?? first?.dueAt {
            addLabel(title: dueTitle, text: dueAt.dateTimeString)
        } else {
            addLabel(title: dueTitle, text: "--", a11y: NSLocalizedString("No due date set.", bundle: .core, comment: ""))
        }

        addLabel(
            title: NSLocalizedString("For:", bundle: .core, comment: ""),
            text: first?.base == true
                ? NSLocalizedString("Everyone", bundle: .core, comment: "")
                : first?.title ?? "-"
        )

        let lockAt = first?.lockAt ?? assignment.lockAt
        if let to = lockAt, to < Clock.now {
            return addLabel(
                title: NSLocalizedString("Availability:", bundle: .core, comment: ""),
                text: NSLocalizedString("Closed", bundle: .core, comment: "")
            )
        }

        let fromTitle = NSLocalizedString("Available From:", bundle: .core, comment: "")
        if let from = first?.unlockAt ?? assignment.unlockAt {
            addLabel(title: fromTitle, text: from.dateTimeString)
        } else {
            addLabel(title: fromTitle, text: "--", a11y: NSLocalizedString("No available from date set.", bundle: .core, comment: ""))
        }

        let toTitle = NSLocalizedString("Available Until:", bundle: .core, comment: "")
        if let to = lockAt {
            addLabel(title: toTitle, text: to.dateTimeString)
        } else {
            addLabel(title: toTitle, text: "--", a11y: NSLocalizedString("No available until date set.", bundle: .core, comment: ""))
        }
    }

    func addLabel(title: String? = nil, text: String, a11y: String? = nil) {
        let label = UILabel()
        label.font = .scaledNamedFont(.regular16)
        label.accessibilityLabel = a11y
        label.textColor = .named(.textDarkest)
        if let title = title {
            let aText = NSMutableAttributedString(string: "\(title) \(text)")
            aText.addAttribute(.font, value: UIFont.scaledNamedFont(.semibold16), range: (title as NSString).range(of: title))
            label.attributedText = aText
        } else {
            label.text = text
        }
        linesView.addArrangedSubview(label)
    }

    @IBAction func route() {
        env.router.route(to: "courses/\(courseID)/assignments/\(assignmentID)/due_dates", from: self)
    }
}
