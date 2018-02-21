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
import PSPDFKit
import ReactiveSwift
import ReactiveCocoa

class SubmitAnnotatedAssignmentViewController: UITableViewController {

    var annotatedFileURL: URL!
    var session: Session!
    var defaultCourseID: String?
    var defaultAssignmentID: String?
    var didSubmitAssignment: ()->Void = { }
    var observer: ManagedObjectObserver<Upload>?

    let newSubmissionViewModel: NewSubmissionViewModelType = NewSubmissionViewModel()

    @IBOutlet var courseCell: UITableViewCell!
    @IBOutlet var assignmentCell: UITableViewCell!

    fileprivate var submissionUploadCompletedDisposable: Disposable?
    fileprivate var submissionUploadFailedDisposable: Disposable?

    var course: Course? {
        didSet {
            if course == nil {
                assignment = nil
                assignmentCell.isUserInteractionEnabled = false
                assignmentCell.textLabel?.textColor = UIColor.lightGray
                courseCell.detailTextLabel?.text = ""
            } else {
                assignmentCell.isUserInteractionEnabled = true
                assignmentCell.textLabel?.textColor = UIColor.black
                courseCell.detailTextLabel?.text = course!.name
            }

            navigationItem.rightBarButtonItem?.isEnabled = (course != nil && assignment != nil)
        }
    }
    // The picked assignment to display
    var assignment: Assignment? {
        didSet {
            assignmentCell.detailTextLabel?.text = assignment?.name ?? ""
            navigationItem.rightBarButtonItem?.isEnabled = (course != nil && assignment != nil)
            if let assignment = assignment {
                newSubmissionViewModel.inputs.configureWith(session: session, assignment: assignment)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showSubmitButton()

        if let defaultCourseID = defaultCourseID {
            let contextID = ContextID(id: defaultCourseID, context: .course)
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
                            let submittable = assignment.allowsSubmissions && assignment.submissionTypes.contains(.upload) && isStudent
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

        bindViewModel()
    }

    fileprivate func bindViewModel() {
        self.newSubmissionViewModel.outputs.showError
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.handleSubmitError($0)
            }

        self.newSubmissionViewModel.outputs.submission
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.uploadSubmitted()
            }
    }

    fileprivate func showSubmitButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Submit", comment: ""), style: .done, target: self, action: #selector(SubmitAnnotatedAssignmentViewController.submit(_:)))
    }

    @IBAction func cancel(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func submit(_ button: UIBarButtonItem) {
        guard let assignment = assignment else { return }

        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.title = NSLocalizedString("Submitting", comment: "")
        courseCell.isUserInteractionEnabled = false
        courseCell.textLabel?.textColor = UIColor.lightGray
        assignmentCell.isUserInteractionEnabled = false
        assignmentCell.textLabel?.textColor = UIColor.lightGray

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        flattenDocument() { url in
            do {
                let data = try Data(contentsOf: url)
                let newUpload = NewFileUpload(kind: .fileURL(url), data: data)
                let context = try self.session.filesManagedObjectContext()
                let fileUpload = FileUpload(inContext: context, uploadable: newUpload, path: assignment.submissionsPath)
                let predicate = NSPredicate(format: "self == %@", fileUpload)

                let uploadChanges = ManagedObjectObserver<FileUpload>.object(predicate: predicate, context: context)
                    .take(during: self.reactive.lifetime)

                uploadChanges
                    .filter { $0.failedAt != nil }
                    .map { $0.errorMessage }
                    .take(first: 1)
                    .observeValues { [weak self] in
                        self?.handleSubmitError($0)
                    }

                uploadChanges
                    .filter { $0.hasCompleted }
                    .map { NewSubmission.fileUpload([$0.file!]) }
                    .take(first: 1)
                    .observeValues { [weak self] in
                        self?.newSubmissionViewModel.inputs.submit(newSubmission: $0)
                    }

                fileUpload.begin(inSession: self.session, inContext: context)
            } catch {
                self.handleSubmitError("Error starting upload: \(error)")
            }
        }
    }

    fileprivate func flattenDocument(_ completion: @escaping (URL)->Void) {
        guard let course = course, let assignment = assignment else { return }

        let document = PSPDFDocument(url: self.annotatedFileURL)
        guard let configuration = PSPDFProcessorConfiguration(document: document) else { return }
        configuration.modifyAnnotations(ofTypes: .all, change: .flatten)

        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        queue.async {
            let cacheDirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
            let outputPath = (cacheDirPath as NSString).appendingPathComponent("\(self.session.user.id)_\(course.id)_\(assignment.id)_submission.pdf")
            if FileManager.default.fileExists(atPath: outputPath) {
                do {
                    try FileManager.default.removeItem(atPath: outputPath)
                } catch {
                    print("Error removing file at path: \(outputPath), error: \(error)")
                }
            }

            do {
                let outputURL = URL(fileURLWithPath: outputPath)
                try PSPDFProcessor.generatePDF(from: configuration, securityOptions: nil, outputFileURL: outputURL, progressBlock: nil)
                DispatchQueue.main.async {
                    completion(outputURL)
                }
            } catch {
                print("Error generating new file with flattened annotations: \(error)")
            }
        }
    }

    fileprivate func handleSubmitError(_ message: String?) {
        let defaultMessage = NSLocalizedString("There was a problem submitting your assignment. Please try again later.", comment: "Message when fails to submit an assignment")
        let alert = UIAlertController(title: NSLocalizedString("Failed to Submit", comment: "Error when submitting an assignment"), message: message ?? defaultMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)

        self.navigationItem.title = nil
        self.showSubmitButton()
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.courseCell.isUserInteractionEnabled = true
        self.courseCell.textLabel?.textColor = UIColor.black
        self.assignmentCell.isUserInteractionEnabled = true
        self.assignmentCell.textLabel?.textColor = UIColor.black
    }

    fileprivate func uploadSubmitted() {
        self.navigationItem.title = NSLocalizedString("Submitted!", comment: "")
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.didSubmitAssignment()
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == tableView.indexPath(for: courseCell) {
            do {
                let collection = try Course.allCoursesCollection(session)
                let dataSource = CollectionTableViewDataSource(collection: collection) { course -> CoursePickerCellViewModel in
                    return CoursePickerCellViewModel(course: course)
                }
                let refresher = try Course.refresher(session)
                let coursePicker = CanvasCore.TableViewController(dataSource: dataSource, refresher: refresher)
                coursePicker.didSelectItemAtIndexPath = { [weak self] indexPath in
                    let course = collection[indexPath]
                    self?.course = course
                    let _ = self?.navigationController?.popViewController(animated: true)
                }
                navigationController?.pushViewController(coursePicker, animated: true)
            } catch {
                print("Error setting up courses collection: \(error)")
            }
        } else if indexPath == tableView.indexPath(for: assignmentCell) {
            guard let course = course else { return }
            do {
                let collection = try Assignment.collectionByDueStatus(session, courseID: course.id)
                let dataSource = CollectionTableViewDataSource(collection: collection) { assignment -> AssignmentPickerCellViewModel in
                    return AssignmentPickerCellViewModel(assignment: assignment, session: self.session)
                }
                let refresher = try Assignment.refresher(session, courseID: course.id)
                let assignmentPicker = CanvasCore.TableViewController(dataSource: dataSource, refresher: refresher)
                assignmentPicker.didSelectItemAtIndexPath = { [weak self] indexPath in
                    let assignment = collection[indexPath]
                    self?.assignment = assignment
                    let _ = self?.navigationController?.popViewController(animated: true)
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

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PickCourseCell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickCourseCell") else {
            fatalError("Incorrect cell type found; expected: PickCourseCell")
        }

        cell.textLabel?.text = course.name

        return cell
    }
}

struct AssignmentPickerCellViewModel: TableViewCellViewModel {
    let assignment: Assignment
    let session: Session

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PickAssignmentCell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickAssignmentCell") else {
            fatalError("Incorrect cell type found; expected: PickAssignmentCell")
        }

        cell.textLabel?.text = assignment.name

        let enrollmentDataSource = session.enrollmentsDataSource[ContextID(id: assignment.courseID, context: .course)]
        let isStudent = enrollmentDataSource?.roles?.contains(EnrollmentRoles.Student) ?? false

        let submittable = assignment.allowsSubmissions && assignment.submissionTypes.contains(.upload) && isStudent
        cell.textLabel?.textColor = submittable ? UIColor.black : UIColor.lightGray
        cell.isUserInteractionEnabled = submittable

        return cell
    }
}

