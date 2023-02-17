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

class StudentDetailsViewController: ScreenViewTrackableViewController, ErrorViewController {
    @IBOutlet var alertFields: [UITextField]!
    @IBOutlet weak var alertHeaderLabel: UILabel!
    @IBOutlet var alertLabels: [UILabel]!
    @IBOutlet var alertSwitches: [UISwitch]!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var scrollView: UIScrollView!

    let env = AppEnvironment.shared
    let formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    var keyboard: KeyboardTransitioning?
    var loadingCount = 0 {
        didSet { updateLoading() }
    }
    var studentID = ""

    lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/profile/observees/\(studentID)/thresholds"
    )

    // lazy var student = env.subscribe(GetObservedStudent(studentID: studentID)) { [weak self] in
    lazy var student: Store<LocalUseCase<User>> = env.subscribe(scope: .where(#keyPath(User.id), equals: studentID)) { [weak self] in
        self?.updateStudent()
    }

    lazy var thresholds = env.subscribe(GetAlertThresholds(studentID: studentID)) { [weak self] in
        self?.updateThresholds()
    }

    func threshold(for type: AlertThresholdType) -> AlertThreshold? {
        return thresholds.first { $0.type == type }
    }

    static func create(studentID: String) -> StudentDetailsViewController {
        let controller = loadFromStoryboard()
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundGrouped

        alertHeaderLabel.text = NSLocalizedString("Alert me when:", comment: "")
        for label in alertLabels {
            label.text = AlertThresholdType.allCases[label.tag].name
        }
        for field in alertFields {
            let type = AlertThresholdType.allCases[field.tag]
            field.accessibilityIdentifier = "AlertThreshold.\(type.rawValue)"
            field.accessibilityLabel = type.name
        }
        for toggle in alertSwitches {
            let type = AlertThresholdType.allCases[toggle.tag]
            toggle.accessibilityIdentifier = "AlertThreshold.\(type.rawValue)"
            toggle.accessibilityLabel = type.name
        }

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        student.refresh()
        thresholds.exhaust()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        let color = ColorScheme.observee(studentID).color
        view.tintColor = color
        navigationController?.navigationBar.useContextColor(color)
    }

    @objc func refresh() {
        thresholds.exhaust(force: true) { [weak self] _ in
            guard self?.thresholds.hasNextPage == false else { return true }
            self?.refreshControl.endRefreshing()
            return false
        }
    }

    func updateStudent() {
        nameLabel.text = student.first.map {
            User.displayName($0.shortName, pronouns: $0.pronouns)
        }
        avatarView.name = student.first?.name ?? ""
        avatarView.url = student.first?.avatarURL
    }

    func updateThresholds() {
        for toggle in alertSwitches {
            let type = AlertThresholdType.allCases[toggle.tag]
            toggle.setOn(threshold(for: type) != nil, animated: true)
        }
        for field in alertFields {
            let type = AlertThresholdType.allCases[field.tag]
            field.text = threshold(for: type)?.threshold.flatMap {
                formatter.string(from: $0)
            }
        }
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        let type = AlertThresholdType.allCases[sender.tag]
        let alert = threshold(for: type)
        if sender.isOn, alert == nil {
            fetch(CreateAlertThreshold(userID: studentID, value: nil, alertType: type))
        } else if !sender.isOn, let id = alert?.id {
            fetch(RemoveAlertThreshold(thresholdID: id))
        }
    }

    @IBAction func fieldChanged(_ sender: UITextField) {
        let type = AlertThresholdType.allCases[sender.tag]
        let text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else {
            if let id = threshold(for: type)?.id {
                fetch(RemoveAlertThreshold(thresholdID: id))
            }
            return
        }
        guard let value = formatter.number(from: text)?.uintValue, value >= 1, value <= 100 else {
            updateThresholds()
            return showAlert(
                title: NSLocalizedString("Invalid Threshold", comment: ""),
                message: NSLocalizedString("The value must a number between 0 and 100", comment: "")
            )
        }

        var low: UInt?
        var high: UInt?
        switch type {
        case .assignmentGradeHigh:
            low = threshold(for: .assignmentGradeLow)?.value
        case .assignmentGradeLow:
            high = threshold(for: .assignmentGradeHigh)?.value
        case .courseGradeHigh:
            low = threshold(for: .courseGradeLow)?.value
        case .courseGradeLow:
            high = threshold(for: .courseGradeHigh)?.value
        case .assignmentMissing, .courseAnnouncement, .institutionAnnouncement:
            break
        }
        if let low = low, low >= value {
            updateThresholds()
            return showAlert(
                title: NSLocalizedString("Invalid Threshold", comment: ""),
                message: NSLocalizedString("You cannot set a high threshold that is lower or equal to a previously set low threshold.", comment: "")
            )
        }
        if let high = high, high <= value {
            updateThresholds()
            return showAlert(
                title: NSLocalizedString("Invalid Threshold", comment: ""),
                message: NSLocalizedString("You cannot set a low threshold that is higher or equal to a previously set high threshold.", comment: "")
            )
        }

        if let alert = threshold(for: type) {
            fetch(UpdateAlertThreshold(thresholdID: alert.id, value: value, alertType: type))
        } else {
            fetch(CreateAlertThreshold(userID: studentID, value: value, alertType: type))
        }
    }

    func fetch<U: UseCase>(_ useCase: U) {
        loadingCount += 1
        useCase.fetch(force: true) { [weak self] _, _, error in performUIUpdate {
            self?.loadingCount -= 1
            if let error = error {
                self?.updateThresholds()
                self?.showError(error)
            }
        } }
    }

    func updateLoading() {
        loadingView.isHidden = loadingCount == 0
    }
}

extension StudentDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
