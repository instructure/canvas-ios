
//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import Foundation

import Eureka
import ReactiveCocoa

import ObserverAlertKit
import Airwolf
import TooLegit
import SoPersistent
import Result
import SoLazy
import Armchair

private enum SupportTicketCellTag: String {
    case Email, Subject, Impact, Comment
}

public class StudentSettingsViewController : FormViewController {

    // UI Elements
    private var cancelButton: UIBarButtonItem!
    private var doneButton: UIBarButtonItem!
    private var removeButton: UIBarButtonItem!
    var removeToolbarItems: [UIBarButtonItem] = []
    private var removeActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var activityToolbarItems: [UIBarButtonItem] = []

    // Injected Vars
    private var session: Session!
    private var studentID: String = ""

    // Data Vars
    var studentObserver: ManagedObjectObserver<Student>?
    private var collection: FetchedCollection<AlertThreshold>?
    var thresholdsRefresher: Refresher?

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "ThresholdsListViewController"
    static func new(session: Session, studentID: String) -> StudentSettingsViewController {
        let controller = StudentSettingsViewController()
        controller.session = session
        controller.studentID = studentID
        controller.thresholdsRefresher = try! AlertThreshold.refresher(session)
        controller.thresholdsRefresher?.refreshingCompleted.observeNext { _ in
            controller.thresholdsRefresher?.refreshControl.endRefreshing()
        }
        controller.thresholdsRefresher?.refreshingBegan.observeNext {
            controller.thresholdsRefresher?.refreshControl.beginRefreshing()
        }
        controller.studentObserver = try! Student.observer(session, studentID: studentID)

        controller.collection = try! AlertThreshold.collectionOfAlertThresholds(session, studentID: studentID)
        controller.collection?.collectionUpdated = { updates in
            controller.updateValues()
        }

        return controller
    }

    // ---------------------------------------------
    // MARK: - UIViewController LifeCycle
    // ---------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton

        setupToolbar()
        setupNavigationBar()

        if let refreshControl = thresholdsRefresher?.refreshControl {
            refreshControl.addTarget(self, action: #selector(StudentSettingsViewController.refresh(_:)), forControlEvents: .ValueChanged)
            tableView?.addSubview(refreshControl)
        }

        studentObserver?.signal.observeOn(UIScheduler()).observeNext{ [unowned self] (change, student) in
            switch change {
            case .Insert, .Update:
                self.tableView?.reloadData()
            case .Delete:
                if let count = try? Student.countOfObservedStudents(self.session) where count == 0 {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }

        let sectionTitle = NSLocalizedString("Alert me when:", comment: "Alert Section Header")
        form +++
            Section() {
                $0.header = studentSectionHeaderView()
            }
            +++ Section(sectionTitle)
            <<< rowForThresholdType(.CourseGradeHigh)
            <<< rowForThresholdType(.CourseGradeLow)
            <<< rowForThresholdType(.AssignmentMissing)
            <<< rowForThresholdType(.AssignmentGradeHigh)
            <<< rowForThresholdType(.AssignmentGradeLow)
            <<< rowForThresholdType(.CourseAnnouncement)

        self.refresh(nil)
    }

    func rowForThresholdType(type: AlertThresholdType) -> BaseRow {
        let percentagePlaceholder = NSLocalizedString("1-100%", comment: "Percentage field placeholder")

        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        switch type {
        case .CourseAnnouncement, .AssignmentMissing:
            let row = SwitchRow(type.rawValue) {
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
                if let threshold = thresholdForType(type), value = threshold.threshold {
                    $0.value = formatter.numberFromString(value)?.integerValue
                }
                }.onCellUnHighlight { [weak self] row in
                    self?.validateValueForRow(type)
                    self?.updateThreshold(type)
                }.onCellHighlight { _ in } // We need a highlight block here in order to trigger the Unhighlight.  Weird Eureka bug
            return row
        }
    }

    func validateValueForRow(type: AlertThresholdType) {
        guard let row = form.rowByTag(type.rawValue) as? IntRow else { ❨╯°□°❩╯⌢"Could not find CourseGradeLow to compare." }

        if row.value > 100 {
            row.value = 100
            notifyUserOfInvalidInput(NSLocalizedString("Cannot use percent that is higher than 100", comment: "Percent value is over 100"))
            return
        }
        if row.value < 0 && row.value != nil {
            row.value = 0
            notifyUserOfInvalidInput(NSLocalizedString("Cannot use percent that is less than 0", comment: "Percent value is under 0"))
            return
        }

        switch type {
        case .CourseAnnouncement, .AssignmentMissing:
            ❨╯°□°❩╯⌢"IntRow should never be used for this Alert Threshold Type"
        case .CourseGradeHigh:
            guard let comparisonRow = form.rowByTag(AlertThresholdType.CourseGradeLow.rawValue) as? IntRow else {
                ❨╯°□°❩╯⌢"Could not find CourseGradeLow to compare."
            }

            if let value = row.value, comparisonValue = comparisonRow.value where value < comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("High course grade cannot be lower than low course grade", comment: "High Course Grade too Low"))
            }
        case .CourseGradeLow:
            guard let comparisonRow = form.rowByTag(AlertThresholdType.CourseGradeHigh.rawValue) as? IntRow else {
                ❨╯°□°❩╯⌢"Could not find CourseGradeLow to compare."
            }

            if let value = row.value, comparisonValue = comparisonRow.value where value > comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("Low course grade cannot be higher than high course grade", comment: "Low Course Grade too High"))
            }
        case .AssignmentGradeHigh:
            guard let comparisonRow = form.rowByTag(AlertThresholdType.AssignmentGradeLow.rawValue) as? IntRow else {
                ❨╯°□°❩╯⌢"Could not find CourseGradeLow to compare."
            }

            if let value = row.value, comparisonValue = comparisonRow.value where value < comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("High assignment grade cannot be lower than low assignment grade", comment: "High Assignment Grade too Low"))
            }
        case .AssignmentGradeLow:
            guard let comparisonRow = form.rowByTag(AlertThresholdType.AssignmentGradeHigh.rawValue) as? IntRow else {
                ❨╯°□°❩╯⌢"Could not find CourseGradeLow to compare."
            }

            if let value = row.value, comparisonValue = comparisonRow.value where value > comparisonValue {
                row.value = comparisonRow.value
                row.updateCell()
                notifyUserOfInvalidInput(NSLocalizedString("Low assignment grade cannot be higher than high assignment grade", comment: "Low Assignment Grade too High"))
            }
        default:
            ❨╯°□°❩╯⌢"IntRow should never be used for this Alert Threshold Type"
        }
    }

    func notifyUserOfInvalidInput(message: String) {
        let title = NSLocalizedString("Invalid Input", comment: "Title for an alert view")

        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .Default, handler: { _ in
        }))

        presentViewController(alert, animated: true, completion: nil)
    }

    func studentSectionHeaderView() -> HeaderFooterView<StudentSettingsHeaderView> {
        var header = HeaderFooterView<StudentSettingsHeaderView>(HeaderFooterProvider.NibFile(name: "StudentSettingsHeaderView", bundle: nil))
        header.onSetupView = { [weak self] view, section in
            guard let me = self, student = me.studentObserver?.object else {
                view.nameLabel.text = ""
                view.imageView.image = UIImage(named: "icon_user")
                return
            }

            view.nameLabel.text = student.sortableName
            if let url = student.avatarURL {
                view.imageView.kf_setImageWithURL(url, placeholderImage: DefaultAvatarCoordinator.defaultAvatarForStudentID(me.studentID))
            }
        }

        return header
    }

    func refresh(refreshControl: UIRefreshControl?) {
        thresholdsRefresher?.refresh(true)
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    func setupNavigationBar() {
        guard let navBar = self.navigationController?.navigationBar as? TriangleGradientNavigationBar else { return }

        let scheme = ColorCoordinator.colorSchemeForStudentID(studentID)
        navBar.transitionToColors(scheme.tintTopColor, bottomTintColor: scheme.tintBottomColor)
    }

    func setupToolbar() {
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        removeButton = UIBarButtonItem(title: NSLocalizedString("Remove", comment: "Remove button title"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(StudentSettingsViewController.removeButtonPressed(_:)))
        removeButton.tintColor = UIColor.redColor()
        removeToolbarItems = [rightSpace, removeButton, leftSpace]
        self.toolbarItems = removeToolbarItems

        let activityIndicatorItem = UIBarButtonItem(customView: removeActivityIndicator)
        activityToolbarItems = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), activityIndicatorItem, UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)]
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    func removeButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to remove this observee?", comment: "Remove Observee Confirmation"), preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .Cancel) { _ in }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove button title"), style: .Destructive) { [unowned self] _ in
            self.removeStudent()
        }
        alertController.addAction(destroyAction)

        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(alertController, animated: true) { }
    }

    func removeStudent() {
        self.toolbarItems = activityToolbarItems
        removeActivityIndicator.startAnimating()
        guard let student = studentObserver?.object else { return }
        student.remove(session) { [unowned self] result in
            dispatch_async(dispatch_get_main_queue()) {
                self.removeActivityIndicator.stopAnimating()
                self.toolbarItems = self.removeToolbarItems
                Armchair.userDidSignificantEvent(true)
            }
        }
    }

    func updateThreshold(type: AlertThresholdType) {
        guard let row = form.rowByTag(type.rawValue) else { return }

        switch type {
        case .CourseAnnouncement, .AssignmentMissing:
            guard let switchRow = row as? SwitchRow else {
                ❨╯°□°❩╯⌢"Row for these types should always be a switch row"
            }

            switchRow.disabled = true
            switchRow.evaluateDisabled()

            guard let threshold = thresholdForType(type) else {
                AlertThreshold.createThreshold(session, type: type, observerID: session.user.id, observeeID: studentID).observeOn(UIScheduler()).startWithCompleted {
                    switchRow.disabled = false
                    switchRow.evaluateDisabled()
                }
                return
            }

            threshold.remove(session).observeOn(UIScheduler()).startWithCompleted {
                switchRow.disabled = false
                switchRow.evaluateDisabled()
            }
        default:
            guard let intRow = row as? IntRow else {
                ❨╯°□°❩╯⌢"Row for these types should always be a int row"
            }

            var thresholdValue: String? = nil
            if let value = intRow.value {
                thresholdValue = "\(value)"
            }

            guard let threshold = thresholdForType(type) else {
                if let value = thresholdValue {
                    AlertThreshold.createThreshold(session, type: type, observerID: session.user.id, observeeID: studentID, threshold: value).start()
                }
                return
            }

            if let value = thresholdValue {
                threshold.update(session, newThreshold: value).start()
            } else {
                threshold.remove(session).start()
            }
        }
    }

    func updateValues() {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        for type in AlertThresholdType.validThresholdTypes {
            guard let row = form.rowByTag(type.rawValue) else { continue }
            switch type {
            case .CourseAnnouncement, .AssignmentMissing:
                guard let boolRow = row as? SwitchRow else {
                    ❨╯°□°❩╯⌢"Row for these types should always be a switch row"
                }

                boolRow.onChange { _ in }
                boolRow.value = thresholdForType(type) != nil
                boolRow.updateCell()
                boolRow.onChange { [weak self] _ in
                    self?.updateThreshold(type)
                }
            default:
                guard let intRow = row as? IntRow else {
                    ❨╯°□°❩╯⌢"Row for these types should always be a int row"
                }

                guard let threshold = thresholdForType(type), value = threshold.threshold else {
                    intRow.value = nil
                    intRow.updateCell()
                    continue
                }

                intRow.value = formatter.numberFromString(value)?.integerValue
                intRow.updateCell()
            }
        }
    }

    func thresholdForType(type: AlertThresholdType) -> AlertThreshold? {
        let matchingThresholds = collection?.filter { threshold -> Bool in
            return threshold.type == type
        }

        return matchingThresholds?.first
    }
    
    func descriptionForType(type: AlertThresholdType) -> String {
        switch type {
        case .CourseGradeLow:
            return NSLocalizedString("Course grade below", comment: "Course Grade Low On Description")
        case .CourseGradeHigh:
            return NSLocalizedString("Course grade above", comment: "Course Grade High On Description")
        case .AssignmentMissing:
            return NSLocalizedString("Assignment missing", comment: "Assignment Missing Description")
        case .AssignmentGradeLow:
            return NSLocalizedString("Assignment grade below", comment: "Assignment Grade Low On Description")
        case .AssignmentGradeHigh:
            return NSLocalizedString("Assignment grade above", comment: "Assignment Grade High On Description")
        case .InstitutionAnnouncement:
            return NSLocalizedString("Institution announcements", comment: "Institution Announcement Description")
        case .CourseAnnouncement:
            return NSLocalizedString("Course announcements", comment: "Course Announcement Description")
        case .Unknown:
            return NSLocalizedString("Unknown", comment: "Unknown T`hreshold Description")
        }
    }
}
