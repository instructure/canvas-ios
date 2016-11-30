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

import UIKit
import SoPersistent
import SoEdventurous
import TooLegit
import SoPretty
import SoIconic
import ReactiveCocoa
import EnrollmentKit

extension MasteryPathAssignment {
    func colorfulViewModel(session: Session, courseID: String) -> ColorfulViewModel {
        let vm = ColorfulViewModel(style: .Basic)
        vm.title.value = name
        vm.accessibilityIdentifier.value = "mastery_path_assignment"

        switch type {
        case .assignment:
            vm.icon.value = .icon(.assignment)
        case .quiz:
            vm.icon.value = .icon(.quiz)
        case .discussionTopic:
            vm.icon.value = .icon(.discussion)
        case .externalTool:
            vm.icon.value = .icon(.lti)
        }

        vm.color <~ session.enrollmentsDataSource.producer(ContextID(id: courseID, context: .Course)).map { $0?.color ?? .prettyGray() }
        vm.accessibilityLabel.value = String(format: NSLocalizedString("%@. Type: %@", comment: "Label to be read for visually impaired users. Name of assingment, then the type of assingment"), name, type.accessibilityLabel)

        return vm
    }
}

class MasteryPathSelectOptionViewController: UIViewController {

    let session: Session
    private let itemWithMasteryPaths: ModuleItem
    private let masteryPathsItem: MasteryPathsItem
    private let masteryPathsItemObserver: ManagedObjectObserver<MasteryPathsItem>

    private let tableViewController = FetchedTableViewController<MasteryPathAssignment>(style: .Grouped)
    private let assignmentSets: [MasteryPathAssignmentSet]

    private let optionSegmentedControl: UISegmentedControl
    private let selectOptionButton: UIButton
    private let selectOptionActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)

    init(session: Session, moduleID: String, itemIDWithMasteryPaths: String) throws {
        self.session = session
        let context = try session.soEdventurousManagedObjectContext()
        if let
            masteryPathsItem: MasteryPathsItem = try context.findOne(withPredicate: MasteryPathsItem.predicateForMasteryPathsItem(inModule: moduleID, fromItemWithMasteryPaths: itemIDWithMasteryPaths)),
            itemWithMasteryPaths: ModuleItem = try context.findOne(withValue: masteryPathsItem.moduleItemID, forKey: "id")
        {
            self.masteryPathsItem = masteryPathsItem
            self.masteryPathsItemObserver = try ManagedObjectObserver(predicate: NSPredicate(format: "%K == %@", "id", masteryPathsItem.id), inContext: context)
            self.itemWithMasteryPaths = itemWithMasteryPaths
        } else {
            throw NSError(subdomain: "Modules", code: 1001, title: NSLocalizedString("No Mastery Paths", comment: "Title for alert when a module item hasn't been set up with mastery paths"), description: NSLocalizedString("This module item doesn't have mastery paths set up.", comment: "Description for alert when a module item doesn't have mastery paths configured"))
        }

        assignmentSets = Array(masteryPathsItem.assignmentSets.allObjects as? [MasteryPathAssignmentSet] ?? []).sort { (s1, s2) in
            return s1.position < s2.position
        }
        let items = assignmentSets.map { String(format: NSLocalizedString("Option %d", comment: "Button title for selecting an option given a number"), $0.position) }
        optionSegmentedControl = UISegmentedControl(items: items)
        optionSegmentedControl.accessibilityIdentifier = "mastery_paths_option_control"
        selectOptionButton = UIButton(type: .Custom)
        selectOptionButton.accessibilityIdentifier = "select_option_button"

        super.init(nibName: nil, bundle: nil)

        if let firstAssignmentSet = assignmentSets.first {
            let collection: FetchedCollection<MasteryPathAssignment> = try MasteryPathAssignment.allAssignmentsInSet(session, assignmentSetID: firstAssignmentSet.id)
            tableViewController.prepare(collection, viewModelFactory: { $0.colorfulViewModel(session, courseID: self.masteryPathsItem.courseID) })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        navigationItem.title = NSLocalizedString("Select Option", comment: "")

        let toolbar = UIToolbar()
        toolbar.barTintColor = Brand.current().navBarTintColor
        toolbar.tintColor = Brand.current().navForegroundColor
        let item = UIBarButtonItem(customView: optionSegmentedControl)
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), item, UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)], animated: false)
        toolbar.delegate = self
        view.addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        toolbar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        toolbar.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true

        tableViewController.willMoveToParentViewController(self)
        addChildViewController(tableViewController)
        view.addSubview(tableViewController.view)
        tableViewController.didMoveToParentViewController(self)

        let tableView = tableViewController.view as! UITableView
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        tableView.topAnchor.constraintEqualToAnchor(toolbar.bottomAnchor, constant: 1.0).active = true
        tableView.accessibilityIdentifier = "assignments_table"

        optionSegmentedControl.addTarget(self, action: #selector(optionChanged), forControlEvents: .ValueChanged)
        optionSegmentedControl.selectedSegmentIndex = 0

        let contextID = ContextID(id: masteryPathsItem.courseID, context: .Course)
        let enrollmentDataSource = session.enrollmentsDataSource[contextID]
        let isStudent = enrollmentDataSource?.roles?.contains(EnrollmentRoles.Student) ?? false
        if isStudent && assignmentSets.count != 0 {
            selectOptionButton.backgroundColor = enrollmentDataSource?.color
            selectOptionButton.setTitle(String(format: NSLocalizedString("Select Option %d", comment: "Button title to select a certain assignment set option"), optionSegmentedControl.selectedSegmentIndex+1), forState: .Normal)
            selectOptionButton.addTarget(self, action: #selector(selectOptionTapped), forControlEvents: .TouchUpInside)
            view.addSubview(selectOptionButton)
            selectOptionButton.translatesAutoresizingMaskIntoConstraints = false
            selectOptionButton.topAnchor.constraintEqualToAnchor(tableView.bottomAnchor).active = true
            selectOptionButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
            selectOptionButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
            selectOptionButton.heightAnchor.constraintEqualToConstant(50.0).active = true
            selectOptionButton.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true

            selectOptionActivityIndicator.hidesWhenStopped = true
            view.insertSubview(selectOptionActivityIndicator, aboveSubview: selectOptionButton)
            selectOptionActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
            selectOptionActivityIndicator.centerXAnchor.constraintEqualToAnchor(selectOptionButton.centerXAnchor).active = true
            selectOptionActivityIndicator.centerYAnchor.constraintEqualToAnchor(selectOptionButton.centerYAnchor).active = true
        } else {
            tableView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        }
    }

    func optionChanged() {
        let idx = optionSegmentedControl.selectedSegmentIndex
        let assignmentSet = assignmentSets[idx]
        do {
            let collection: FetchedCollection<MasteryPathAssignment> = try MasteryPathAssignment.allAssignmentsInSet(session, assignmentSetID: assignmentSet.id)
            tableViewController.prepare(collection, viewModelFactory: { $0.colorfulViewModel(self.session, courseID: self.masteryPathsItem.courseID) })
        } catch {
            print("Error switching assignment sets: \(error)")
        }

        selectOptionButton.setTitle(String(format: NSLocalizedString("Select Option %d", comment: "Button title to select a certain assignment set option"), optionSegmentedControl.selectedSegmentIndex+1), forState: .Normal)
    }

    func selectOptionTapped() {
        let idx = optionSegmentedControl.selectedSegmentIndex
        let assignmentSet = assignmentSets[idx]
        selectOptionButton.setTitle("", forState: .Normal)
        selectOptionActivityIndicator.startAnimating()
        do {
            try itemWithMasteryPaths.selectMasteryPath(session, assignmentSetID: assignmentSet.id).startWithResult { [weak self] result in
                self?.selectOptionActivityIndicator.stopAnimating()
                switch result {
                case .Success:
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.navigationController?.popViewControllerAnimated(true)
                    }
                case .Failure(let error):
                    self?.selectOptionButton.setTitle(String(format: NSLocalizedString("Select Option %d", comment: "Button title to select a certain assignment set option"), (self?.optionSegmentedControl.selectedSegmentIndex ?? 0)+1), forState: .Normal)
                    error.report(true, alertUserFrom: self, onDismiss: nil)
                }
            }
        } catch let error as NSError {
            error.report(true, alertUserFrom: self, onDismiss: nil)
        }
    }
}

extension MasteryPathSelectOptionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let assignment = tableViewController.collection[indexPath]
        if let vc = try? MasteryPathAssignmentPreviewViewController(session: session, assignment: assignment) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MasteryPathSelectOptionViewController: UIToolbarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
