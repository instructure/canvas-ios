//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import Eureka
import ReactiveSwift
import CanvasCore

private enum SupportTicketCellTag: String {
    case Email, Subject, Impact, Comment
}

open class StudentSettingsViewController : FormViewController {

    @objc let activityIndicator = UIActivityIndicatorView(style: .white)
    
    // Injected Vars
    fileprivate var session: Session!
    fileprivate var studentID: String = ""

    // Data Vars
    var studentObserver: ManagedObjectObserver<Student>?
    fileprivate var collection: FetchedCollection<AlertThreshold>?
    var thresholdsRefresher: Refresher?
    fileprivate var observeUpdatesDisposable: Disposable?

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    fileprivate static let defaultStoryboardName = "ThresholdsListViewController"
    @objc static func new(_ session: Session, studentID: String) -> StudentSettingsViewController {
        let controller = StudentSettingsViewController()
        controller.session = session
        controller.studentID = studentID
        controller.thresholdsRefresher = try! AlertThreshold.refresher(session, studentID: studentID)
        _ = controller.thresholdsRefresher?.refreshingCompleted.observeValues { _ in
            controller.thresholdsRefresher?.refreshControl.endRefreshing()
        }
        _ = controller.thresholdsRefresher?.refreshingBegan.observeValues {
            controller.thresholdsRefresher?.refreshControl.beginRefreshing()
        }
        controller.studentObserver = try! Student.observer(session, studentID: studentID)

        controller.collection = try! AlertThreshold.collectionOfAlertThresholds(session, studentID: studentID)
        controller.observeUpdatesDisposable = controller.collection?.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { updates in
                controller.updateValues()
            }.map(ScopedDisposable.init)

        return controller
    }

    // ---------------------------------------------
    // MARK: - UIViewController LifeCycle
    // ---------------------------------------------
    open override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()

        if let refreshControl = thresholdsRefresher?.refreshControl {
            refreshControl.addTarget(self, action: #selector(StudentSettingsViewController.refresh(_:)), for: .valueChanged)
            tableView?.addSubview(refreshControl)
        }

        _ = studentObserver?.signal.observe(on: UIScheduler()).observeValues{ [unowned self] (change, student) in
            switch change {
            case .insert, .update:
                self.tableView?.reloadData()
            case .delete:
                if let count = try? Student.countOfObservedStudents(self.session), count == 0 {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }

        let sectionTitle = NSLocalizedString("Alert me when:", comment: "Alert Section Header")
        form +++
            Section() {
                $0.header = self.studentSectionHeaderView()
            }
            +++ Section(sectionTitle)
            <<< rowForThresholdType(.courseGradeHigh)
            <<< rowForThresholdType(.courseGradeLow)
            <<< rowForThresholdType(.assignmentMissing)
            <<< rowForThresholdType(.assignmentGradeHigh)
            <<< rowForThresholdType(.assignmentGradeLow)
            <<< rowForThresholdType(.courseAnnouncement)
            <<< rowForThresholdType(.institutionAnnouncement)

        self.refresh(nil)
    }

    func rowForThresholdType(_ type: AlertThresholdType) -> BaseRow {
        let percentagePlaceholder = NSLocalizedString("1-100%", comment: "Percentage field placeholder")

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        switch type {
        case .courseAnnouncement, .assignmentMissing, .institutionAnnouncement:
            let row = SwitchRow(type.rawValue) {
                $0.cellSetup { c, _ in
                    c.isAccessibilityElement = true
                }
                $0.title = self.descriptionForType(type)
                if let _ = thresholdForType(type) {
                    $0.value = true
                }
                }.onChange { [weak self] _ in
                    self?.updateThreshold(type)
            }
            return row
        default:
            let row = IntRow(type.rawValue) {
                $0.title = self.descriptionForType(type)
                $0.placeholder = percentagePlaceholder
                $0.textFieldPercentage = 0.20
                if let threshold = thresholdForType(type), let value = threshold.threshold {
                    $0.value = formatter.number(from: value)?.intValue
                }
                }.onCellHighlightChanged { [weak self] (_, _) in
                    self?.validateValueForRow(type)
                    self?.updateThreshold(type)
                }
            return row
        }
    }

    func validateValueForRow(_ type: AlertThresholdType) {
        guard let row = form.rowBy(tag: type.rawValue) as? IntRow else { fatalError("Could not find CourseGradeLow to compare.") }
        
        let value = row.value ?? 0

        if value > 100 {
            row.value = 100
            notifyUserOfInvalidInput(NSLocalizedString("Cannot use percent that is higher than 100", comment: "Percent value is over 100"))
            return
        }
        if value < 0 && row.value != nil {
            row.value = 0
            notifyUserOfInvalidInput(NSLocalizedString("Cannot use percent that is less than 0", comment: "Percent value is under 0"))
            return
        }

        switch type {
        case .courseAnnouncement, .assignmentMissing:
            fatalError("IntRow should never be used for this Alert Threshold Type")
        case .courseGradeHigh:
            guard let comparisonRow = form.rowBy(tag: AlertThresholdType.courseGradeLow.rawValue) as? IntRow else {
                fatalError("Could not find CourseGradeLow to compare.")
            }

            if let value = row.value, let comparisonValue = comparisonRow.value, value < comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("High course grade cannot be lower than low course grade", comment: "High Course Grade too Low"))
            }
        case .courseGradeLow:
            guard let comparisonRow = form.rowBy(tag: AlertThresholdType.courseGradeHigh.rawValue) as? IntRow else {
                fatalError("Could not find CourseGradeLow to compare.")
            }

            if let value = row.value, let comparisonValue = comparisonRow.value, value > comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("Low course grade cannot be higher than high course grade", comment: "Low Course Grade too High"))
            }
        case .assignmentGradeHigh:
            guard let comparisonRow = form.rowBy(tag: AlertThresholdType.assignmentGradeLow.rawValue) as? IntRow else {
                fatalError("Could not find CourseGradeLow to compare.")
            }

            if let value = row.value, let comparisonValue = comparisonRow.value, value < comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("High assignment grade cannot be lower than low assignment grade", comment: "High Assignment Grade too Low"))
            }
        case .assignmentGradeLow:
            guard let comparisonRow = form.rowBy(tag: AlertThresholdType.assignmentGradeHigh.rawValue) as? IntRow else {
                fatalError("Could not find CourseGradeLow to compare.")
            }

            if let value = row.value, let comparisonValue = comparisonRow.value, value > comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("Low assignment grade cannot be higher than high assignment grade", comment: "Low Assignment Grade too High"))
            }
        default:
            fatalError("IntRow should never be used for this Alert Threshold Type")
        }
    }

    @objc func notifyUserOfInvalidInput(_ message: String) {
        let title = NSLocalizedString("Invalid Input", comment: "Title for an alert view")

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }

    func studentSectionHeaderView() -> HeaderFooterView<StudentSettingsHeaderView> {
        var header = HeaderFooterView<StudentSettingsHeaderView>(HeaderFooterProvider.nibFile(name: "StudentSettingsHeaderView", bundle: nil))
        header.onSetupView = { [weak self] view, section in
            guard let me = self, let student = me.studentObserver?.object else {
                view.nameLabel.text = ""
                view.imageView.image = UIImage(named: "icon_user")
                return
            }

            view.nameLabel.text = student.name
            if let url = student.avatarURL {
                view.imageView.kf.setImage(with: url, placeholder: DefaultAvatarCoordinator.defaultAvatarForStudentID(me.studentID))
            }
        }

        return header
    }

    @objc func refresh(_ refreshControl: UIRefreshControl?) {
        thresholdsRefresher?.refresh(true)
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    @objc func setupNavigationBar() {
        guard let navBar = self.navigationController?.navigationBar else { return }

        let scheme = ColorCoordinator.colorSchemeForStudentID(studentID)
        navBar.backgroundColor = scheme.mainColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.hidesWhenStopped = true
    }

    func updateThreshold(_ type: AlertThresholdType) {
        guard let row = form.rowBy(tag: type.rawValue) else { return }
        
        let onComplete = { (event: ReactiveSwift.Signal<Bool, NSError>.Event) -> Void in
            switch(event) {
            case .failed(let error):
                self.displayError(error: error)
                self.activityIndicator.stopAnimating()
                break
            default:
                self.activityIndicator.stopAnimating()
            }
        }

        activityIndicator.startAnimating()
        
        switch type {
        case .courseAnnouncement, .assignmentMissing, .institutionAnnouncement:
            guard let switchRow = row as? SwitchRow else {
                fatalError("Row for these types should always be a switch row")
            }

            switchRow.disabled = true
            switchRow.evaluateDisabled()

            guard let threshold = thresholdForType(type) else {
                AlertThreshold.createThreshold(session, type: type, observerID: session.user.id, observeeID: studentID).observe(on: UIScheduler()).start { event in
                    onComplete(event)
                    switch event {
                    case .completed, .failed:
                        switchRow.disabled = false
                        switchRow.evaluateDisabled()
                    default:
                        break
                    }
                }
                return
            }

            threshold.remove(session).observe(on: UIScheduler()).start { event in
                onComplete(event)
                switch event {
                case .completed, .failed:
                    switchRow.disabled = false
                    switchRow.evaluateDisabled()
                default:
                    break
                }
            }
        default:
            guard let intRow = row as? IntRow else {
                fatalError("Row for these types should always be a int row")
            }

            var thresholdValue: String? = nil
            if let value = intRow.value {
                thresholdValue = "\(value)"
            }

            guard let threshold = thresholdForType(type) else {
                if let value = thresholdValue {
                    AlertThreshold.createThreshold(session, type: type, observerID: session.user.id, observeeID: studentID, threshold: value).start(onComplete)
                } else {
                    activityIndicator.stopAnimating()
                }
                return
            }
            
            let signal: SignalProducer<Bool, NSError>
            if let value = thresholdValue {
                signal = threshold.update(session, newThreshold: value)
            } else {
                signal = threshold.remove(session)
            }
            
            signal.start(onComplete)
        }
    }

    @objc func updateValues() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        for type in AlertThresholdType.validThresholdTypes {
            guard let row = form.rowBy(tag: type.rawValue) else { continue }
            switch type {
            case .courseAnnouncement, .assignmentMissing, .institutionAnnouncement:
                guard let boolRow = row as? SwitchRow else {
                    fatalError("Row for these types should always be a switch row")
                }

                boolRow.onChange { _ in }
                boolRow.value = thresholdForType(type) != nil
                boolRow.updateCell()
                boolRow.onChange { [weak self] _ in
                    self?.updateThreshold(type)
                }
            default:
                guard let intRow = row as? IntRow else {
                    fatalError("Row for these types should always be a int row")
                }

                guard let threshold = thresholdForType(type), let value = threshold.threshold else {
                    intRow.value = nil
                    intRow.updateCell()
                    continue
                }

                intRow.value = formatter.number(from: value)?.intValue
                intRow.updateCell()
            }
        }
    }

    func thresholdForType(_ type: AlertThresholdType) -> AlertThreshold? {
        let matchingThresholds = collection?.filter { threshold -> Bool in
            return threshold.type == type
        }

        return matchingThresholds?.first
    }
    
    func descriptionForType(_ type: AlertThresholdType) -> String {
        switch type {
        case .courseGradeLow:
            return NSLocalizedString("Course grade below", comment: "Course Grade Low On Description")
        case .courseGradeHigh:
            return NSLocalizedString("Course grade above", comment: "Course Grade High On Description")
        case .assignmentMissing:
            return NSLocalizedString("Assignment missing", comment: "Assignment Missing Description")
        case .assignmentGradeLow:
            return NSLocalizedString("Assignment grade below", comment: "Assignment Grade Low On Description")
        case .assignmentGradeHigh:
            return NSLocalizedString("Assignment grade above", comment: "Assignment Grade High On Description")
        case .institutionAnnouncement:
            return NSLocalizedString("Institution announcements", comment: "Institution Announcement Description")
        case .courseAnnouncement:
            return NSLocalizedString("Course announcements", comment: "Course Announcement Description")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "Unknown T`hreshold Description")
        }
    }
    
    @objc func displayError(error: NSError) {
        let title = NSLocalizedString("An Error Occurred", comment: "")
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        present(alert, animated: true)
    }
}
