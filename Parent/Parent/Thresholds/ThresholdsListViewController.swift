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

import CoreData

import SoPersistent
import TooLegit
import ObserverAlertKit
import ReactiveCocoa
import Marshal
import Airwolf

class ThresholdsListViewController: UITableViewController {

    let userInfoSection = 0
    let thresholdSection = 1

    var session: Session!
    var studentID: String!

    var studentObserver: ManagedObjectObserver<Student>?
    var studentSyncProducer: SignalProducer<[Student], NSError>?
    var collection: FetchedCollection<AlertThreshold>?
    var syncProducer: SignalProducer<[AlertThreshold], NSError>?

    // UI Views
    var selectedTextField: UITextField?
    var removeButton: UIBarButtonItem!
    var removeToolbarItems: [UIBarButtonItem] = []
    var removeActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var activityToolbarItems: [UIBarButtonItem] = []
    var doneToolbar: UIToolbar!
    var doneKeyboardButton: UIBarButtonItem!

    // Data Variables
    var thresholdTypes: [AlertThresholdType] = []

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "ThresholdsListViewController"
    static func new(storyboardName: String = defaultStoryboardName, session: Session, studentID: String) -> ThresholdsListViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? ThresholdsListViewController else {
            fatalError("Initial ViewController is not of type ThresholdsListViewController")
        }

        controller.session = session
        controller.studentID = studentID
        controller.studentObserver = try! Student.observer(session, studentID: studentID)
        // TOOD: is there a better way of syncing just one student without an api call for a single one?
        // This should pull the whole list, then the observer will pick up any changes to that given object
        controller.studentSyncProducer = try! Student.observedStudentsSyncProducer(session)

        return controller
    }

    // ---------------------------------------------
    // MARK: - ViewController Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupToolbar()
        loadThresholdTypes()
        do {
            try setupCollection()
        } catch let error as NSError {
            print(error)
        }

        studentObserver?.signal.observeOn(UIScheduler()).observeNext{ [unowned self] (change, student) in
            switch change {
            case .Insert, .Update:
                self.tableView.reloadData()
            case .Delete:
                if let count = try? Student.countOfObservedStudents(self.session) where count == 0 {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }

        tableView.estimatedRowHeight = 44
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.defaultTableViewBackgroundColor()
        self.refresh(nil)
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    func setupNavigationBar() {
        if let navBar = self.navigationController?.navigationBar as? TriangleGradientNavigationBar {
            let scheme = ColorCoordinator.colorSchemeForStudentID(studentID)
            navBar.transitionToColors(scheme.tintTopColor, bottomTintColor: scheme.tintBottomColor)
        }
    }

    func setupCollection() throws {
        collection = try AlertThreshold.collectionOfObserveeAlertThresholds(session, observeeID: studentID)
        collection?.collectionUpdated = { [unowned self] updates in
            self.tableView.reloadData()
        }
    }

    func setupToolbar() {
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        removeButton = UIBarButtonItem(title: NSLocalizedString("Remove", comment: "Remove Observee Button"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ThresholdsListViewController.removeButtonPressed(_:)))
        removeButton.tintColor = UIColor.redColor()
        removeToolbarItems = [rightSpace, removeButton, leftSpace]
        self.toolbarItems = removeToolbarItems

        let activityIndicatorItem = UIBarButtonItem(customView: removeActivityIndicator)
        activityToolbarItems = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), activityIndicatorItem, UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)]

        doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        doneKeyboardButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(keyboardDonePressed(_:)))
        doneToolbar.setItems([flexBarButton, doneKeyboardButton], animated: false)
    }

    func refresh(refreshContol: UIRefreshControl?) {
        guard let syncProducer = syncProducer, observeeSyncProducer = studentSyncProducer else { return }

        syncProducer.start { event in
            switch event {
            case .Failed(let e):
                print(e.localizedDescription)
                e.presentAlertFromViewController(self, alertDismissed: nil)
                fallthrough
            case .Completed, .Interrupted:
                self.tableView.reloadData()
                refreshContol?.endRefreshing()
            default: break
            }
        }

        observeeSyncProducer.start { event in
            switch event {
            case .Failed(let e):
                print(e.localizedDescription)
                e.presentAlertFromViewController(self, alertDismissed: nil)
                fallthrough
            case .Completed, .Interrupted:
                // TODO: should be handled by the managed object observer now
                // self.tableView.reloadData()
                // TODO: one could finish first before and then still cause a reload
                refreshContol?.endRefreshing()
            default: break
            }
        }
    }

    // ---------------------------------------------
    // MARK: - UITableView DataSource
    // ---------------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case userInfoSection:
            return NSLocalizedString("Observee Info Title", value: "Observee", comment: "Observee Info Title")
        default:
            return NSLocalizedString("Thresholds Title", value: "Notify me when:", comment: "Thresholds Title")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case userInfoSection:
            return 1
        default:
            return thresholdTypes.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // first section is user info cell
        guard indexPath.section != userInfoSection else {
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ObserveeDetailCell", forIndexPath: indexPath) as? ObserveeDetailCell else {
                fatalError("Incorrect cell type found. Expected: ObserveeDetailCell")
            }

            configureUserCell(cell, forRowAtIndexPath: indexPath)
            return cell
        }

        // second Section is
        guard let cell = tableView.dequeueReusableCellWithIdentifier("ChangeThresholdsCell", forIndexPath: indexPath) as? ChangeThresholdsCell else {
            fatalError("Incorrect cell type found. Expected: ChangeThresholdsCell")
        }

        configureCell(cell, forRowAtIndexPath: indexPath)

        return cell
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        switch section {
        case userInfoSection:
            title = NSLocalizedString("Observee Info Title", value: "Observee", comment: "Observee Info Title")
        default:
            title = NSLocalizedString("Thresholds Title", value: "Notify me when:", comment: "Thresholds Title")
        }

        let view = TableSectionHeaderView()
        view.text = title
        return view
    }
    
    func configureCell(cell: ChangeThresholdsCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let thresholdType = thresholdTypes[indexPath.row]

        cell.toggle.tag = indexPath.row
        cell.thresholdInput.tag = indexPath.row
        cell.thresholdInput.delegate = self
        cell.thresholdInput.inputAccessoryView = doneToolbar
        cell.toggle.addTarget(self, action: #selector(ThresholdsListViewController.thresholdToggled(_:)), forControlEvents: .ValueChanged)

        guard let threshold = thresholdForType(thresholdType) else {
            // Set Default values here
            cell.toggle.on = false
            cell.thresholdInput.hidden = true
            cell.titleLabel.text = thresholdType.offDescription
            return
        }

        cell.titleLabel.text = thresholdType.onDescription
        cell.toggle.on = true
        cell.thresholdInput.hidden = !thresholdType.allowsThresholdValue
        cell.thresholdInput.text = threshold.threshold
    }

    func configureUserCell(cell: ObserveeDetailCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let student = studentObserver?.object else {
            cell.nameLabel.text = ""
            cell.avatarImageView.image = UIImage(named: "icon_user")
            return
        }

        cell.nameLabel.text = student.name

        let avatarImageView = cell.avatarImageView
        avatarImageView.layer.cornerRadius = CGRectGetHeight(avatarImageView.frame)/2
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.borderWidth = 2.0
        avatarImageView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .ScaleAspectFit
        if let url = student.avatarURL {
            avatarImageView.kf_setImageWithURL(url, placeholderImage: DefaultAvatarCoordinator.defaultAvatarForStudentID(studentID))
        }
    }

    // ---------------------------------------------
    // MARK: - Fetch Data
    // ---------------------------------------------
    func loadThresholdTypes() {
        thresholdTypes = [
            .CourseGradeLow,
            .CourseGradeHigh,
            .AssignmentMissing,
            .AssignmentGradeLow,
            .AssignmentGradeHigh,
//            .InstitutionAnnouncement,
            .CourseAnnouncement
        ]
    }

    func thresholdToggled(toggle: UISwitch) {
        guard let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: toggle.tag, inSection: thresholdSection)) as? ChangeThresholdsCell else {
            return
        }

        let index = toggle.tag
        let thresholdType = thresholdTypes[index]
        let thresholdInputOn = (toggle.on && thresholdType.allowsThresholdValue)
        cell.thresholdInput.hidden = !thresholdInputOn
        if thresholdInputOn {
            cell.thresholdInput.becomeFirstResponder()
        }

        cell.titleLabel.text = toggle.on ? thresholdType.onDescription : thresholdType.offDescription

        // sync to remove the threshold if the toggle is off
        if !toggle.on {
            cell.thresholdInput.text = ""
            removeThresholdAtIndex(index)
            selectedTextField?.resignFirstResponder()
        } else {
            // if this threshold doesn't need additional values lets create an object for it
            if !thresholdType.allowsThresholdValue {
                createThresholdAtIndex(index)
            }
        }

    }

    func thresholdForType(type: AlertThresholdType) -> AlertThreshold? {
        let matchingThresholds = collection?.filter { threshold -> Bool in
            return threshold.type == type
        }

        return matchingThresholds?.first
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    func removeButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to remove this observee?", comment: "Remove Observee Confirmation"), preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Remove Observee Cancel Button"), style: .Cancel) { _ in }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove Observee Confirm Button"), style: .Destructive) { [unowned self] _ in
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
            }
        }
    }

    func keyboardDonePressed(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
}

// ---------------------------------------------
// MARK: - Networking Calls
// ---------------------------------------------
extension ThresholdsListViewController {
    func removeThresholdAtIndex(index: Int) {
        let thresholdType = thresholdTypes[index]
        guard let threshold = thresholdForType(thresholdType) else { return }
        threshold.remove(session)
    }

    func createThresholdAtIndex(index: Int, thresholdValue: String? = nil) {
        let thresholdType = thresholdTypes[index]
        AlertThreshold.createThreshold(session, type: thresholdType, observerID: session.user.id, observeeID: studentID, threshold: thresholdValue)
    }

    func updateThresholdAtIndex(index: Int, thresholdValue: String) {
        let thresholdType = thresholdTypes[index]
        guard let threshold = thresholdForType(thresholdType) else { return }
        threshold.update(session, newThreshold: thresholdValue)
    }
}

extension ThresholdsListViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
        doneKeyboardButton.enabled = true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // TODO: Should we do more than just disable button when text is invalid
        let thresholdValue = 100
        guard let currentString = textField.text else {
            return true
        }

        let currentText = NSString(string: currentString)
        let textAfterUpdate = currentText.stringByReplacingCharactersInRange(range, withString: string)

        let numFormatter = NSNumberFormatter()
        numFormatter.numberStyle = .DecimalStyle
        if numFormatter.numberFromString(textAfterUpdate)?.integerValue > thresholdValue {
            doneKeyboardButton.enabled = false
        } else {
            doneKeyboardButton.enabled = true
        }

        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        let index = textField.tag
        guard let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: thresholdSection)) as? ChangeThresholdsCell,
            value = textField.text where
            cell.toggle.on else {
            return
        }

        // if we don't have a threshold, create one
        let thresholdType = thresholdTypes[index]
        guard let _ = thresholdForType(thresholdType) else {
            createThresholdAtIndex(index, thresholdValue: textField.text)
            return
        }

        // update it already
        updateThresholdAtIndex(index, thresholdValue: value)
    }
}