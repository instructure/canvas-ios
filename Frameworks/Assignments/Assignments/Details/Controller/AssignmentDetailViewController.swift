//
//  AssignmentDeets.swift
//  Assignments
//
//  Created by Derrick Hathaway on 3/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import AssignmentKit
import SoPersistent
import SoLazy
import TooLegit
import ReactiveCocoa
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
        let button = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(AssignmentDetailViewController.turnIn(_:)))
        button.tintColor = UIColor.whiteColor()
        return button
    }()
    lazy var lockedButton: UIButton = {
        let lockedImage = UIImage(named: "icon_locked_fill")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let lockedButton = UIButton(type: UIButtonType.Custom) as UIButton
        lockedButton.frame = CGRectMake(0, 0, 40, 40)
        lockedButton.setImage(lockedImage, forState: .Normal)
        lockedButton.tintColor = UIColor.whiteColor()
        return lockedButton
    }()

    var uploadFRC: NSFetchedResultsController?

    private var session: Session?
    private var uploadBuilder: UploadBuilder?
    private var beginDragY: CGFloat = 0
    private let notificationHandler = LocalNotificationHandler.sharedInstance

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func new(session: Session, courseID: String, assignmentID: String) throws -> AssignmentDetailViewController {
        guard let me = UIStoryboard(name: "Assignment", bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? AssignmentDetailViewController else {
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
            }, viewSubmissionsHandler: { [weak me] in
                print("Once this is merged into iCanvas route to submissions view controller here.")
            }
        ))
        
        me.session = session
        
        me.disposable = observer.signal.map { $0.1 }
            .observeOn(UIScheduler())
            .observeNext { [weak me] assignment in
                me?.updateReminderButton(assignment)
                me?.updateTurnInButton(assignment)
            }
        
        return me
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         notificationHandler.notificationApplication = UIApplication.sharedApplication()
        
        // toolbar
        let left = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let right = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.toolbarItems = [left, submissionBarButtonItem, right]
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.toolbar.barTintColor = Brand.current().secondaryTintColor

        guard let assignment = observer.object, session = session else {
            return
        }

        do {
            uploadFRC = try Upload.inProgressFRC(session, identifier: assignment.submissionUploadIdentifier)
            uploadFRC?.delegate = self
            try uploadFRC?.performFetch()
            updateUploadProgress()
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        
        if let assignment = self.observer.object {
            updateReminderButton(assignment)
            updateTurnInButton(assignment)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // Mark: Turn In
    
    func updateTurnInButton(assignment: Assignment?) {
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
        
        guard let assignment = assignment where assignment.allowsSubmissions else {
            return
        }
        
        guard !assignment.lockedForUser else {
            customView = lockedButton
            return
        }

        let resubmit = NSLocalizedString("Re-submit Assignment", comment: "title for submission button if student has submitted previously")
        let submit = NSLocalizedString("Submit Assignment", comment: "title for submission button if student has never submitted")
        
        title = assignment.hasSubmitted ? resubmit : submit
    }
    
    func turnIn(button: UIBarButtonItem) {
        var turnInError: NSError?
        
        defer {
            turnInError?.presentAlertFromViewController(self)
        }

        guard let assignment = observer.object, session = session else {
            turnInError = NSError(subdomain: "Assignments.submit", description: NSLocalizedString("Could not submit assignment. Invalid assignment or session.", comment: "error displayed when submitting an assignment is unavailable"))
            return
        }
        let uploadTypes: UploadTypes = assignment.getUploadTypesFromSubmissionTypes()
        let builder = UploadBuilder(viewController: self, barButtonItem: button, submissionTypes: uploadTypes, allowsAudio: assignment.allowsAudio, allowsPhotos: assignment.allowsPhotos, allowsVideo: assignment.allowsVideo, allowedUploadUTIs: assignment.allowedSubmissionUTIs, allowedImagePickerControllerMediaTypes: assignment.allowedImagePickerControllerMediaTypes)
        //let builder = UploadBuilder(assignment: assignment, viewController: self, barButtonItem: button)
        builder.uploadSelected = { newUpload in
            do {
                try assignment.uploadSubmission(newUpload, inSession: session)
            } catch {
                turnInError = NSError(subdomain: "Assignments.submit", description: NSLocalizedString("Could not submit assignment. Invalid submission.", comment: "error displayed when submitting a submission is invalid."))
            }
        }
        
        self.uploadBuilder = builder

        builder.beginUpload()
    }

    // Mark: Reminders
    
    func updateReminderButton(assignment: Assignment?) {
        //Don't show reminders for undated assignments
        guard let assignment = assignment, dueDate = assignment.due else { return }
        
        //Don't show reminders for past due assignments
        if dueDate.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            return
        } else {
            setReminderButton(notificationHandler.localNotificationExists(assignment.id))
        }
    }
    
    private func setReminderButton(alarmExists: Bool) {
        var alarmImage = UIImage(named: "icon_alarm")
        if (alarmExists) {
            alarmImage = UIImage(named: "icon_alarm_fill")
        }
        
        if (notificationHandler.canScheduleLocalNotifications()) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: alarmImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(scheduleReminderTapped))
        } else {
            navigationItem.rightBarButtonItem = nil
            print("Local Notifications not allowed")
        }
    }
    
    func scheduleReminderTapped(sender: UIBarButtonItem) {
        guard let assignment = self.observer.object else { return }
        
        if (notificationHandler.localNotificationExists(assignment.id)) {
            notificationHandler.removeLocalNotification(assignment.id)
        } else {
            presentActionSheet()
        }
        
        setReminderButton(notificationHandler.localNotificationExists(assignment.id))
    }
    
    private func presentActionSheet() {
        guard let assignment = self.observer.object else { return }
        guard let barButtonItem = self.navigationItem.rightBarButtonItem else { return }
        
        if let dueDate = assignment.due {
            let notifiableAssignment = NotifiableObject(due: dueDate, name: assignment.name, url: assignment.url, id: assignment.id)
            
            let title = NSLocalizedString("Assignment Reminder", comment: "Title for alert view for assignment reminders")
            let message = NSLocalizedString("Choose how long before the assignment due date to get a reminder:", comment: "Title for reminder options for an assignment")
            let cancel = NSLocalizedString("Cancel", comment: "cancel button")
            let fiveMinutes = NSLocalizedString("5 minutes", comment: "Title for 5 minutes assignment reminder")
            let oneHour = NSLocalizedString("1 hour", comment: "Title for 1 hour assignment reminder")
            let oneDay = NSLocalizedString("1 day", comment: "Title for 1 day assignment reminder")
            let threeDays = NSLocalizedString("3 days", comment: "Title for 3 days assignment reminder")
            
            let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: cancel, style: .Cancel) { action -> Void in
                actionSheet.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let fiveMinutesAction: UIAlertAction = UIAlertAction(title: fiveMinutes, style: .Default) { action -> Void in
                self.notificationHandler.scheduleLocaNotification(notifiableAssignment, offsetInMinutes: 5)
                self.updateReminderButton(assignment)
            }
            
            let oneHourAction: UIAlertAction = UIAlertAction(title: oneHour, style: .Default) { action -> Void in
                self.notificationHandler.scheduleLocaNotification(notifiableAssignment, offsetInMinutes: LocalNotificationConstants.LocalNotificationNumberMinutesInHour)
                self.updateReminderButton(assignment)
            }
            
            let oneDayAction: UIAlertAction = UIAlertAction(title: oneDay, style: .Default) { action -> Void in
                self.notificationHandler.scheduleLocaNotification(notifiableAssignment, offsetInMinutes: LocalNotificationConstants.LocalNotificationNumberMinutesInDay)
                self.updateReminderButton(assignment)
            }
            
            let threeDaysAction: UIAlertAction = UIAlertAction(title: threeDays, style: .Default) { action -> Void in
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
                let buttonItemView = barButtonItem.valueForKey("view") as! UIView
                
                popoverController.sourceRect = CGRectMake(buttonItemView.frame.origin.x, 0, buttonItemView.frame.width, 0)
                popoverController.permittedArrowDirections = UIPopoverArrowDirection.Up
            }
            
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
}

extension AssignmentDetailViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if controller == uploadFRC {
            dispatch_async(dispatch_get_main_queue()) {
                self.updateUploadProgress()
            }
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let submissionUpload = anObject as? SubmissionUpload where submissionUpload.hasCompleted {
            self.refresher?.refresh(true)
        }
    }

    private func updateUploadProgress() {
        guard let uploads = uploadFRC?.fetchedObjects as? [Upload] where !uploads.isEmpty else {
            self.submissionBarButtonItem.enabled = true
            self.updateTurnInButton(self.observer.object)
            return
        }

        self.submissionBarButtonItem.enabled = false

        var bytesSent = 0
        var bytesTotal = 0
        for upload in uploads {
            bytesSent += Int(upload.sent)
            bytesTotal += Int(upload.total)
        }

        let progress = hashProgress(n: bytesSent, d: bytesTotal)
        self.submissionBarButtonItem.title = progress
    }
}

typealias ProgressBar = (n: Int, d: Int) -> String

// [####      ] (40%)
let hashProgress: ProgressBar = { n, d in
    guard d > 0 && n <= d else { return "[] (0%)" }
    let max = 10
    let p = (n*100)/d
    let x = (p*10)/100
    let hss = Array(count: x, repeatedValue: "#").joinWithSeparator("")
    let blanks = Array(count: 10 - x, repeatedValue: " ").joinWithSeparator("")
    return "[\(hss)\(blanks)] (\(p)%)"
}
