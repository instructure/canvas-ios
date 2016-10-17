//
//  SubmitAnnotatedAssignmentViewController.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 8/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import PSPDFKit
import EnrollmentKit
import AssignmentKit
import FileKit
import TooLegit
import SoPersistent
import SoPretty
import ReactiveCocoa

class SubmitAnnotatedAssignmentViewController: UITableViewController {

    var annotatedFileURL: NSURL!
    var session: Session!
    var defaultCourseID: String?
    var defaultAssignmentID: String?
    var didSubmitAssignment: (Void)->Void = { }
    var observer: ManagedObjectObserver<Upload>?

    @IBOutlet var courseCell: UITableViewCell!
    @IBOutlet var assignmentCell: UITableViewCell!

    private var submissionUploadCompletedDisposable: Disposable?
    private var submissionUploadFailedDisposable: Disposable?

    var course: Course? {
        didSet {
            if course == nil {
                assignment = nil
                assignmentCell.userInteractionEnabled = false
                assignmentCell.textLabel?.textColor = UIColor.lightGrayColor()
                courseCell.detailTextLabel?.text = ""
            } else {
                assignmentCell.userInteractionEnabled = true
                assignmentCell.textLabel?.textColor = UIColor.blackColor()
                courseCell.detailTextLabel?.text = course!.name
            }

            navigationItem.rightBarButtonItem?.enabled = (course != nil && assignment != nil)
        }
    }
    // The picked assignment to display
    var assignment: Assignment? {
        didSet {
            assignmentCell.detailTextLabel?.text = assignment?.name ?? ""
            navigationItem.rightBarButtonItem?.enabled = (course != nil && assignment != nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showSubmitButton()

        if let defaultCourseID = defaultCourseID {
            let contextID = ContextID(id: defaultCourseID, context: .Course)
            do {
                let course = try Course.findOne(contextID, inContext: try session.enrollmentManagedObjectContext()) as? Course
                self.course = course

                let enrollmentDataSource = session.enrollmentsDataSource[contextID]
                let isStudent = enrollmentDataSource?.roles?.contains(EnrollmentRoles.Student) ?? false
                if isStudent {
                    if let defaultAssignmentID = defaultAssignmentID {
                        let context = try session.assignmentsManagedObjectContext()
                        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", "id", defaultAssignmentID, "courseID", defaultCourseID)
                        if let assignment: Assignment = try context.findOne(withPredicate: predicate) {
                            let submittable = assignment.allowsSubmissions && assignment.submissionTypes.contains(SubmissionTypes.Upload) && isStudent
                            if submittable {
                                self.assignment = assignment
                            }
                        }
                    }
                }
            } catch {
                course = nil
            }
        } else {
            course = nil
        }
    }

    private func showSubmitButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Submit", comment: ""), style: .Done, target: self, action: #selector(SubmitAnnotatedAssignmentViewController.submit(_:)))
    }

    @IBAction func cancel(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func submit(button: UIBarButtonItem) {
        guard let assignment = assignment else { return }

        navigationItem.leftBarButtonItem?.enabled = false
        navigationItem.title = NSLocalizedString("Submitting", comment: "")
        courseCell.userInteractionEnabled = false
        courseCell.textLabel?.textColor = UIColor.lightGrayColor()
        assignmentCell.userInteractionEnabled = false
        assignmentCell.textLabel?.textColor = UIColor.lightGrayColor()

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        flattenDocument() { url in
            let newUpload = NewUpload.FileUpload([NewUploadFile.FileURL(url)])
            do {
                try assignment.uploadForNewSubmission(newUpload, inSession: self.session) { submissionUpload in
                    guard let submissionUpload = submissionUpload else { print("Failed to begin the submission upload"); return }

                    let handleError: (String) -> Void = { [weak self] message in
                        let alert = UIAlertController(title: NSLocalizedString("Failed to Submit", comment: "Error when submitting an assignment"), message: message, preferredStyle: .Alert)
                        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil)
                        alert.addAction(action)
                        self?.presentViewController(alert, animated: true, completion: nil)

                        self?.navigationItem.title = nil
                        self?.showSubmitButton()
                        self?.navigationItem.leftBarButtonItem?.enabled = true
                        self?.courseCell.userInteractionEnabled = true
                        self?.courseCell.textLabel?.textColor = UIColor.blackColor()
                        self?.assignmentCell.userInteractionEnabled = true
                        self?.assignmentCell.textLabel?.textColor = UIColor.blackColor()
                    }

                    do {
                        self.observer = try Upload.observer(self.session, id: submissionUpload.id)
                        self.submissionUploadCompletedDisposable = self.observer!.signal.observeNext { [weak self] change, upload in
                            if let upload = upload {
                                guard upload.failedAt == nil else {
                                    let message = NSLocalizedString("There was a problem submitting your assignment. Please try again later.", comment: "Message when fails to submit an assignment")
                                    handleError(upload.errorMessage ?? message)
                                    return
                                }

                                if upload.hasCompleted {
                                    self?.navigationItem.title = NSLocalizedString("Submitted!", comment: "")
                                    self?.navigationItem.rightBarButtonItem = nil
                                    self?.navigationItem.leftBarButtonItem = nil

                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                                        self?.didSubmitAssignment()
                                        self?.dismissViewControllerAnimated(true, completion: nil)
                                    }
                                }
                            }
                        }

                        submissionUpload.begin(inSession: self.session, inContext: try self.session.assignmentsManagedObjectContext())
                    } catch let e as NSError {
                        handleError(e.localizedDescription)
                    }

                }
            } catch {
                print("Error starting upload for assignment submission: \(error)")
            }
        }
    }

    private func flattenDocument(completion: (NSURL)->Void) {
        guard let course = course, assignment = assignment else { return }

        let document = PSPDFDocument(URL: self.annotatedFileURL)
        guard let configuration = PSPDFProcessorConfiguration(document: document) else { return }
        configuration.modifyAnnotationsOfTypes(.All, change: .Flatten)

        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async(queue) {
            let cacheDirPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
            let outputPath = (cacheDirPath as NSString).stringByAppendingPathComponent("\(self.session.user.id)_\(course.id)_\(assignment.id)_submission.pdf")
            if NSFileManager.defaultManager().fileExistsAtPath(outputPath) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(outputPath)
                } catch {
                    print("Error removing file at path: \(outputPath), error: \(error)")
                }
            }

            do {
                let outputURL = NSURL(fileURLWithPath: outputPath)
                try PSPDFProcessor.generatePDFFromConfiguration(configuration, saveOptions: nil, outputFileURL: outputURL, progressBlock: nil)
                dispatch_async(dispatch_get_main_queue()) {
                    completion(outputURL)
                }
            } catch {
                print("Error generating new file with flattened annotations: \(error)")
            }
        }
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == tableView.indexPathForCell(courseCell) {
            do {
                let collection = try Course.allCoursesCollection(session)
                let dataSource = CollectionTableViewDataSource(collection: collection) { course -> CoursePickerCellViewModel in
                    return CoursePickerCellViewModel(course: course)
                }
                let refresher = try Course.refresher(session)
                let coursePicker = SoPersistent.TableViewController(dataSource: dataSource, refresher: refresher)
                coursePicker.didSelectItemAtIndexPath = { [weak self] indexPath in
                    let course = collection[indexPath]
                    self?.course = course
                    self?.navigationController?.popViewControllerAnimated(true)
                }
                navigationController?.pushViewController(coursePicker, animated: true)
            } catch {
                print("Error setting up courses collection: \(error)")
            }
        } else if indexPath == tableView.indexPathForCell(assignmentCell) {
            guard let course = course else { return }
            do {
                let collection = try Assignment.collectionByDueStatus(session, courseID: course.id)
                let dataSource = CollectionTableViewDataSource(collection: collection) { assignment -> AssignmentPickerCellViewModel in
                    return AssignmentPickerCellViewModel(assignment: assignment, session: self.session)
                }
                let refresher = try Assignment.refresher(session, courseID: course.id)
                let assignmentPicker = SoPersistent.TableViewController(dataSource: dataSource, refresher: refresher)
                assignmentPicker.didSelectItemAtIndexPath = { [weak self] indexPath in
                    let assignment = collection[indexPath]
                    self?.assignment = assignment
                    self?.navigationController?.popViewControllerAnimated(true)
                }
                navigationController?.pushViewController(assignmentPicker, animated: true)
            } catch {
                print("Error setting up assignments collection: \(error)")
            }
        }
    }
}


struct CoursePickerCellViewModel: TableViewCellViewModel {
    let course: Course

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "PickCourseCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("PickCourseCell") else {
            fatalError("Incorrect cell type found; expected: PickCourseCell")
        }

        cell.textLabel?.text = course.name

        return cell
    }
}

struct AssignmentPickerCellViewModel: TableViewCellViewModel {
    let assignment: Assignment
    let session: Session

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "PickAssignmentCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("PickAssignmentCell") else {
            fatalError("Incorrect cell type found; expected: PickAssignmentCell")
        }

        cell.textLabel?.text = assignment.name

        let enrollmentDataSource = session.enrollmentsDataSource[ContextID(id: assignment.courseID, context: .Course)]
        let isStudent = enrollmentDataSource?.roles?.contains(EnrollmentRoles.Student) ?? false

        let submittable = assignment.allowsSubmissions && assignment.submissionTypes.contains(SubmissionTypes.Upload) && isStudent
        cell.textLabel?.textColor = submittable ? UIColor.blackColor() : UIColor.lightGrayColor()
        cell.userInteractionEnabled = submittable

        return cell
    }
}

