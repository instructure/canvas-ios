//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import AssignmentKit
import SoPersistent
import SoLazy
import TooLegit
import ReactiveSwift
import SoPretty
import CoreData
import FileKit

// Mark: Custom Cells

class AssignmentGradeSubmissionTableViewCell: UITableViewCell {
    @IBOutlet var verticalLineWidth: NSLayoutConstraint!
    @IBOutlet var rightView: UIView!
    @IBOutlet var separator: UIView!
    @IBOutlet var leftView: UIView!
}

class AssignmentPaddingCell: UITableViewCell {
    @IBOutlet var horizontalLineHeight: NSLayoutConstraint!
    @IBOutlet var horizontalLineView: UIView!
}

// Mark: View Controller

struct LocalNotificationConstants {
    static let LocalNotificationNumberMinutesInHour : Int = 60
    static let LocalNotificationNumberMinutesInDay : Int =  LocalNotificationNumberMinutesInHour * 24
}

class AssignmentDetailViewController: Assignment.DetailViewController {
    var disposable: Disposable?
    var uploadDisposable = CompositeDisposable()
    lazy var submissionBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(AssignmentDetailViewController.turnIn(_:)))
        button.tintColor = UIColor.white
        return button
    }()
    lazy var lockedButton: UIButton = {
        let lockedImage = UIImage(named: "icon_locked_fill")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let lockedButton = UIButton(type: UIButtonType.custom) as UIButton
        lockedButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        lockedButton.setImage(lockedImage, for: UIControlState())
        lockedButton.tintColor = UIColor.white
        return lockedButton
    }()

    fileprivate var session: Session?
    fileprivate var beginDragY: CGFloat = 0
    fileprivate let notificationHandler = LocalNotificationHandler.sharedInstance

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func new(_ session: Session, courseID: String, assignmentID: String) throws -> AssignmentDetailViewController {
        guard let me = UIStoryboard(name: "Assignment", bundle: Bundle(for: self)).instantiateInitialViewController() as? AssignmentDetailViewController else {
                fatalError()
            }
        
        let observer = try Assignment.observer(session, courseID: courseID, assignmentID: assignmentID)
        let refresher = try Assignment.refresher(session, courseID: courseID, assignmentID: assignmentID)
        
        me.prepare(observer, refresher: refresher, detailsFactory: AssignmentDetailCellViewModel.detailsForAssignment(session, viewRubricHandler: { [weak me] in
                print("Once this is merged into iCanvas route to rubric view controller from here.")

                do {
                    let rubricViewController : RubricViewController = try RubricViewController.new(session, courseID: courseID, assignmentID: assignmentID)
                    
                    me?.navigationController?.pushViewController(rubricViewController, animated: true)
                } catch _ as NSError {
                    
                }
            }, viewSubmissionsHandler: { _ in
                print("Once this is merged into iCanvas route to submissions view controller here.")
            }
        ))
        
        me.session = session
        
        me.disposable = observer.signal.map { $0.1 }
            .observe(on: UIScheduler())
            .observeValues { [weak me] assignment in
                me?.updateReminderButton(assignment)
                me?.updateTurnInButton(assignment)
            }
        
        return me
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         notificationHandler.notificationApplication = UIApplication.shared
        
        // toolbar
        let left = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let right = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.toolbarItems = [left, submissionBarButtonItem, right]
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.toolbar.barTintColor = Brand.current().secondaryTintColor

        guard let assignment = observer.object, let session = session else {
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        
        if let assignment = self.observer.object {
            updateReminderButton(assignment)
            updateTurnInButton(assignment)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // Mark: Turn In
    
    func updateTurnInButton(_ assignment: Assignment?) {
        var title: String? = nil
        var customView: UIView? = nil

        defer {
            submissionBarButtonItem.title = title
            if title == nil {
                submissionBarButtonItem.customView = customView
            }
            if (self.navigationController?.topViewController == self) {
                navigationController?.setToolbarHidden((title == nil && customView == nil), animated: true)
            }
        }
        
        guard let assignment = assignment, assignment.allowsSubmissions else {
            return
        }
        
        guard !assignment.lockedForUser else {
            customView = lockedButton
            return
        }

        let resubmit = NSLocalizedString("Re-submit Assignment", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "title for submission button if student has submitted previously")
        let submit = NSLocalizedString("Submit Assignment", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "title for submission button if student has never submitted")
        
        title = assignment.hasSubmitted ? resubmit : submit
    }
    
    func turnIn(_ button: UIBarButtonItem) {
        var turnInError: NSError?
        
        defer {
            turnInError?.presentAlertFromViewController(self)
        }

        guard let assignment = observer.object, let session = session else {
            turnInError = NSError(subdomain: "Assignments.submit", description: NSLocalizedString("Could not submit assignment. Invalid assignment or session.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "error displayed when submitting an assignment is unavailable"))
            return
        }
    }

    // Mark: Reminders
    
    func updateReminderButton(_ assignment: Assignment?) {
        //Don't show reminders for undated assignments
        guard let assignment = assignment, let dueDate = assignment.due else { return }
        
        //Don't show reminders for past due assignments
        if dueDate.compare(Date()) == ComparisonResult.orderedAscending {
            return
        } else {
            setReminderButton(notificationHandler.localNotificationExists(assignment.id))
        }
    }
    
    fileprivate func setReminderButton(_ alarmExists: Bool) {
        var alarmImage = UIImage(named: "icon_alarm")
        if (alarmExists) {
            alarmImage = UIImage(named: "icon_alarm_fill")
        }
        
        if (notificationHandler.canScheduleLocalNotifications()) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: alarmImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(scheduleReminderTapped))
        } else {
            navigationItem.rightBarButtonItem = nil
            print("Local Notifications not allowed")
        }
    }
    
    func scheduleReminderTapped(_ sender: UIBarButtonItem) {
        guard let assignment = self.observer.object else { return }
        
        if (notificationHandler.localNotificationExists(assignment.id)) {
            notificationHandler.removeLocalNotification(assignment.id)
        } else {
            presentActionSheet()
        }
        
        setReminderButton(notificationHandler.localNotificationExists(assignment.id))
    }
    
    fileprivate func presentActionSheet() {
        guard let assignment = self.observer.object else { return }
        guard let barButtonItem = self.navigationItem.rightBarButtonItem else { return }
        
        if let dueDate = assignment.due {
            let notifiableAssignment = NotifiableObject(due: dueDate, name: assignment.name, url: assignment.url, id: assignment.id)
            
            let title = NSLocalizedString("Assignment Reminder", tableName: "Localizable", bundle: .assignments(), comment: "Title for alert view for assignment reminders")
            let message = NSLocalizedString("Choose how long before the assignment due date to get a reminder:", tableName: "Localizable", bundle: .assignments(), comment: "Title for reminder options for an assignment")
            let cancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .assignments(), comment: "cancel button")
            let fiveMinutes = NSLocalizedString("5 minutes", tableName: "Localizable", bundle: .assignments(), comment: "Title for 5 minutes assignment reminder")
            let oneHour = NSLocalizedString("1 hour", tableName: "Localizable", bundle: .assignments(), comment: "Title for 1 hour assignment reminder")
            let oneDay = NSLocalizedString("1 day", tableName: "Localizable", bundle: .assignments(), comment: "Title for 1 day assignment reminder")
            let threeDays = NSLocalizedString("3 days", tableName: "Localizable", bundle: .assignments(), comment: "Title for 3 days assignment reminder")
            
            let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: cancel, style: .cancel) { action -> Void in
                actionSheet.dismiss(animated: true, completion: nil)
            }
            
            let fiveMinutesAction: UIAlertAction = UIAlertAction(title: fiveMinutes, style: .default) { action -> Void in
                self.notificationHandler.scheduleLocaNotification(notifiableAssignment, offsetInMinutes: 5)
                self.updateReminderButton(assignment)
            }
            
            let oneHourAction: UIAlertAction = UIAlertAction(title: oneHour, style: .default) { action -> Void in
                self.notificationHandler.scheduleLocaNotification(notifiableAssignment, offsetInMinutes: LocalNotificationConstants.LocalNotificationNumberMinutesInHour)
                self.updateReminderButton(assignment)
            }
            
            let oneDayAction: UIAlertAction = UIAlertAction(title: oneDay, style: .default) { action -> Void in
                self.notificationHandler.scheduleLocaNotification(notifiableAssignment, offsetInMinutes: LocalNotificationConstants.LocalNotificationNumberMinutesInDay)
                self.updateReminderButton(assignment)
            }
            
            let threeDaysAction: UIAlertAction = UIAlertAction(title: threeDays, style: .default) { action -> Void in
                self.notificationHandler.scheduleLocaNotification(notifiableAssignment, offsetInMinutes: LocalNotificationConstants.LocalNotificationNumberMinutesInDay * 3)
                self.updateReminderButton(assignment)
            }
            
            actionSheet.addAction(cancelAction)
            actionSheet.addAction(fiveMinutesAction)
            actionSheet.addAction(oneHourAction)
            actionSheet.addAction(oneDayAction)
            actionSheet.addAction(threeDaysAction)
            
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                let buttonItemView = barButtonItem.value(forKey: "view") as! UIView
                
                popoverController.sourceRect = CGRect(x: buttonItemView.frame.origin.x, y: 0, width: buttonItemView.frame.width, height: 0)
                popoverController.permittedArrowDirections = UIPopoverArrowDirection.up
            }
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
}
