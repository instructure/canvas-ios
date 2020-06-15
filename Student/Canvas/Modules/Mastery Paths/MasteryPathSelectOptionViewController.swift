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

import UIKit
import ReactiveSwift
import CanvasCore
import Core

extension CanvasCore.MasteryPathAssignment {
    func colorfulViewModel(_ session: Session, courseID: String) -> ColorfulViewModel {
        let vm = ColorfulViewModel(features: [.icon])
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

        vm.color <~ session.enrollmentsDataSource.color(for: .course(courseID))
        vm.accessibilityLabel.value = String(format: NSLocalizedString("%@. Type: %@", comment: "Label to be read for visually impaired users. Name of assingment, then the type of assingment"), name, type.accessibilityLabel)

        return vm
    }
}

class MasteryPathSelectOptionViewController: UIViewController {

    @objc let session: Session
    fileprivate let itemWithMasteryPaths: CanvasCore.ModuleItem
    fileprivate let masteryPathsItem: MasteryPathsItem
    fileprivate let masteryPathsItemObserver: ManagedObjectObserver<MasteryPathsItem>

    fileprivate let tableViewController = FetchedTableViewController<CanvasCore.MasteryPathAssignment>(style: .grouped)
    fileprivate let assignmentSets: [CanvasCore.MasteryPathAssignmentSet]

    fileprivate let optionSegmentedControl: UISegmentedControl
    fileprivate let selectOptionButton: UIButton
    fileprivate let selectOptionActivityIndicator = UIActivityIndicatorView(style: .white)

    @objc init(session: Session, moduleID: String, itemIDWithMasteryPaths: String) throws {
        self.session = session
        let context = try session.soEdventurousManagedObjectContext()
        if let
            masteryPathsItem: MasteryPathsItem = try context.findOne(withPredicate: MasteryPathsItem.predicateForMasteryPathsItem(inModule: moduleID, fromItemWithMasteryPaths: itemIDWithMasteryPaths)),
            let itemWithMasteryPaths: CanvasCore.ModuleItem = try context.findOne(withValue: masteryPathsItem.moduleItemID, forKey: "id")
        {
            self.masteryPathsItem = masteryPathsItem
            self.masteryPathsItemObserver = try ManagedObjectObserver(predicate: NSPredicate(format: "%K == %@", "id", masteryPathsItem.id), inContext: context)
            self.itemWithMasteryPaths = itemWithMasteryPaths
        } else {
            throw NSError(subdomain: "Modules", code: 1001, title: NSLocalizedString("No Mastery Paths", comment: "Title for alert when a module item hasn't been set up with mastery paths"), description: NSLocalizedString("This module item doesn't have mastery paths set up.", comment: "Description for alert when a module item doesn't have mastery paths configured"))
        }

        assignmentSets = Array(masteryPathsItem.assignmentSets.allObjects as? [CanvasCore.MasteryPathAssignmentSet] ?? []).sorted { (s1, s2) in
            return s1.position < s2.position
        }
        let items = assignmentSets.map { String(format: NSLocalizedString("Option %d", comment: "Button title for selecting an option given a number"), $0.position) }
        optionSegmentedControl = UISegmentedControl(items: items)
        optionSegmentedControl.accessibilityIdentifier = "mastery_paths_option_control"
        selectOptionButton = UIButton(type: .custom)
        selectOptionButton.accessibilityIdentifier = "select_option_button"

        super.init(nibName: nil, bundle: nil)

        if let firstAssignmentSet = assignmentSets.first {
            let collection: FetchedCollection<CanvasCore.MasteryPathAssignment> = try MasteryPathAssignment.allAssignmentsInSet(session, assignmentSetID: firstAssignmentSet.id)
            tableViewController.prepare(collection, viewModelFactory: { $0.colorfulViewModel(session, courseID: self.masteryPathsItem.courseID) })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        navigationItem.title = NSLocalizedString("Select Option", comment: "")

        let toolbar = UIToolbar()
        let item = UIBarButtonItem(customView: optionSegmentedControl)
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), item, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)], animated: false)
        toolbar.delegate = self
        view.addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        tableViewController.willMove(toParent: self)
        addChild(tableViewController)
        view.addSubview(tableViewController.view)
        tableViewController.didMove(toParent: self)

        let tableView = tableViewController.view as! UITableView
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 1.0).isActive = true
        tableView.accessibilityIdentifier = "assignments_table"

        optionSegmentedControl.addTarget(self, action: #selector(optionChanged), for: .valueChanged)
        optionSegmentedControl.selectedSegmentIndex = 0

        let contextID = Context(.course, id: masteryPathsItem.courseID)
        let enrollment = session.enrollmentsDataSource[contextID]
        let isStudent = enrollment?.roles?.contains(EnrollmentRoles.Student) ?? false
        if isStudent && assignmentSets.count != 0 {
            selectOptionButton.backgroundColor = enrollment?.color.value
            selectOptionButton.setTitle(String(format: NSLocalizedString("Select Option %d", comment: "Button title to select a certain assignment set option"), optionSegmentedControl.selectedSegmentIndex+1), for: UIControl.State())
            selectOptionButton.addTarget(self, action: #selector(selectOptionTapped), for: .touchUpInside)
            view.addSubview(selectOptionButton)
            selectOptionButton.translatesAutoresizingMaskIntoConstraints = false
            selectOptionButton.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
            selectOptionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            selectOptionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            selectOptionButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
            selectOptionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

            selectOptionActivityIndicator.hidesWhenStopped = true
            view.insertSubview(selectOptionActivityIndicator, aboveSubview: selectOptionButton)
            selectOptionActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
            selectOptionActivityIndicator.centerXAnchor.constraint(equalTo: selectOptionButton.centerXAnchor).isActive = true
            selectOptionActivityIndicator.centerYAnchor.constraint(equalTo: selectOptionButton.centerYAnchor).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }

    @objc func optionChanged() {
        let idx = optionSegmentedControl.selectedSegmentIndex
        let assignmentSet = assignmentSets[idx]
        do {
            let collection: FetchedCollection<CanvasCore.MasteryPathAssignment> = try MasteryPathAssignment.allAssignmentsInSet(session, assignmentSetID: assignmentSet.id)
            tableViewController.prepare(collection, viewModelFactory: { $0.colorfulViewModel(self.session, courseID: self.masteryPathsItem.courseID) })
        } catch {
            print("Error switching assignment sets: \(error)")
        }

        selectOptionButton.setTitle(String(format: NSLocalizedString("Select Option %d", comment: "Button title to select a certain assignment set option"), optionSegmentedControl.selectedSegmentIndex+1), for: UIControl.State())
    }

    @objc func selectOptionTapped() {
        let idx = optionSegmentedControl.selectedSegmentIndex
        let assignmentSet = assignmentSets[idx]
        selectOptionButton.setTitle("", for: UIControl.State())
        selectOptionActivityIndicator.startAnimating()
        do {
            try itemWithMasteryPaths.selectMasteryPath(session: session, assignmentSetID: assignmentSet.id).startWithResult { [weak self] result in
                DispatchQueue.main.async {
                    self?.selectOptionActivityIndicator.stopAnimating()
                    switch result {
                    case .success:
                        self?.dismiss(animated: true, completion: nil)
                    case .failure(let error):
                        self?.selectOptionButton.setTitle(String(format: NSLocalizedString("Select Option %d", comment: "Button title to select a certain assignment set option"), (self?.optionSegmentedControl.selectedSegmentIndex ?? 0)+1), for: .normal)
                        ErrorReporter.reportError(error, from: self)
                    }
                }
            }
        } catch let error as NSError {
            ErrorReporter.reportError(error, from: self)
        }
    }
}

extension MasteryPathSelectOptionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assignment = tableViewController.collection[indexPath]
        if let vc = try? MasteryPathAssignmentPreviewViewController(session: session, assignment: assignment) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MasteryPathSelectOptionViewController: UIToolbarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
