//
// Copyright (C) 2018-present Instructure, Inc.
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

import Core
import UIKit
import MobileCoreServices

class AssignmentDetailsViewController: UIViewController, AssignmentDetailsViewProtocol {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var pointsLabel: UILabel?
    @IBOutlet weak var statusIconView: UIImageView?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var dueHeadingLabel: UILabel?
    @IBOutlet weak var dueLabel: UILabel?
    @IBOutlet weak var submissionTypesHeadingLabel: UILabel?
    @IBOutlet weak var submissionTypesLabel: UILabel?
    @IBOutlet weak var fileTypesDivider: DividerView?
    @IBOutlet weak var fileTypesHeadingLabel: UILabel?
    @IBOutlet weak var fileTypesLabel: UILabel?
    @IBOutlet weak var gradeHeadingLabel: UILabel?
    @IBOutlet weak var descriptionHeadingLabel: UILabel?
    @IBOutlet weak var descriptionView: CoreWebView?
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var loadingView: UIActivityIndicatorView?
    @IBOutlet weak var submissionButtonView: UIView?
    @IBOutlet weak var submissionButton: DynamicButton?
    @IBOutlet weak var submissionButtonIcon: UIImageView?
    @IBOutlet weak var submissionButtonDivider: DividerView?
    @IBOutlet weak var fileSubmissionButton: DynamicButton?

    @IBOutlet weak var gradeCell: UIView?
    @IBOutlet weak var gradeCellDivider: DividerView?
    @IBOutlet weak var gradedView: GradeCircleView?
    @IBOutlet weak var gradeCircleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submittedView: UIView?
    @IBOutlet weak var submittedLabel: UILabel?
    @IBOutlet weak var submittedDetailsLabel: UILabel?
    @IBOutlet weak var submitAssignmentButton: DynamicButton!
    @IBOutlet weak var scrollviewInsetConstraint: NSLayoutConstraint!

    @IBOutlet weak var quizAttemptsLabel: UILabel?
    @IBOutlet weak var quizAttemptsValueLabel: UILabel?
    @IBOutlet weak var quizHeadingLabel: UILabel?
    @IBOutlet weak var quizQuestionsLabel: UILabel?
    @IBOutlet weak var quizQuestionsValueLabel: UILabel?
    @IBOutlet weak var quizTimeLimitLabel: UILabel?
    @IBOutlet weak var quizTimeLimitValueLabel: UILabel?
    @IBOutlet weak var quizView: UIView?

    let scrollViewInsetPadding: CGFloat = 24.0

    var refreshControl: UIRefreshControl?
    let titleSubtitleView = TitleSubtitleView.create()
    var presenter: AssignmentDetailsPresenter?

    static func create(env: AppEnvironment = .shared, courseID: String, assignmentID: String, fragment: String? = nil) -> AssignmentDetailsViewController {
        let controller = loadFromStoryboard()
        controller.presenter = AssignmentDetailsPresenter(env: env, view: controller, courseID: courseID, assignmentID: assignmentID, fragment: fragment)
        return controller
    }

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = NSLocalizedString("Assignment Details", bundle: .student, comment: "")

        // Loading
        scrollView?.isHidden = true
        loadingView?.color = Brand.shared.primary.ensureContrast(against: .named(.white))
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        scrollView?.addSubview(refreshControl)
        self.refreshControl = refreshControl

        // Localization
        dueHeadingLabel?.text = NSLocalizedString("Due", bundle: .student, comment: "")
        submissionTypesHeadingLabel?.text = NSLocalizedString("Submission Types", bundle: .student, comment: "")
        fileTypesHeadingLabel?.text = NSLocalizedString("File Types", bundle: .student, comment: "")
        gradeHeadingLabel?.text = NSLocalizedString("Grade", bundle: .student, comment: "")
        descriptionHeadingLabel?.text = NSLocalizedString("Description", bundle: .student, comment: "")
        quizAttemptsLabel?.text = NSLocalizedString("Allowed Attempts:", bundle: .student, comment: "")
        quizHeadingLabel?.text = NSLocalizedString("Settings", bundle: .student, comment: "")
        quizQuestionsLabel?.text = NSLocalizedString("Questions:", bundle: .student, comment: "")
        quizTimeLimitLabel?.text = NSLocalizedString("Time Limit:", bundle: .student, comment: "")
        submittedLabel?.text = NSLocalizedString("Successfully submitted!", bundle: .student, comment: "")
        submittedDetailsLabel?.text = NSLocalizedString("Your submission is now waiting to be graded", bundle: .student, comment: "")
        submissionButton?.setTitle(NSLocalizedString("Submission & Rubric", bundle: .student, comment: ""), for: .normal)

        // Routing from description
        descriptionView?.navigation = .deepLink { (url: URL) -> Bool? in
            return self.presenter?.route(to: url, from: self)
        }

        // Debug background upload
        #if DEBUG
        let exit = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(debugExit))
        addNavigationButton(exit, side: .right)
        #endif

        presenter?.viewIsReady()
    }

    @objc
    func refresh(_ refreshControl: UIRefreshControl) {
        presenter?.refresh()
    }

    @objc
    func debugExit() {
        exit(EXIT_SUCCESS)
    }

    @IBAction
    func viewFileSubmission() {
        presenter?.submit(.online_upload, from: self)
    }

    func updateNavBar(subtitle: String?, backgroundColor: UIColor?) {
        titleSubtitleView.subtitle = subtitle
        navigationController?.navigationBar.useContextColor(backgroundColor)
    }

    func hideGradeCell() {
        gradeCell?.isHidden = true
        gradeCellDivider?.isHidden = true
    }

    func updateGradeCell(_ assignment: Assignment) {
        self.gradedView?.update(assignment)

        // in this case the submission should always be there because canvas generates
        // submissions for every user for every assignment but just in case
        guard let submission = assignment.submission else {
            hideGradeCell()
            return
        }

        submittedLabel?.textColor = UIColor.named(.textSuccess).ensureContrast(against: .white)
        submittedLabel?.text = NSLocalizedString("Successfully submitted!", bundle: .student, comment: "")

        if let fileSubmissionState = presenter?.fileSubmissionState {
            gradeCell?.isHidden = false
            gradeCellDivider?.isHidden = false
            gradedView?.isHidden = true
            submittedView?.isHidden = false
            fileSubmissionButton?.isHidden = false
            submittedDetailsLabel?.isHidden = true
            switch fileSubmissionState {
            case .failed:
                submittedLabel?.text = NSLocalizedString("Submission Failed", bundle: .core, comment: "")
                submittedLabel?.textColor = UIColor.named(.textDanger).ensureContrast(against: .white)
                fileSubmissionButton?.setTitle(NSLocalizedString("Tap to view details", bundle: .core, comment: ""), for: .normal)
            case .pending:
                submittedLabel?.text = NSLocalizedString("Submission Uploading...", bundle: .core, comment: "")
                submittedLabel?.textColor = UIColor.named(.textSuccess).ensureContrast(against: .white)
                fileSubmissionButton?.setTitle(NSLocalizedString("Tap to view progress", bundle: .core, comment: ""), for: .normal)
            }
            return
        }

        guard submission.workflowState != .unsubmitted else {
            hideGradeCell()
            return
        }

        gradeCell?.isHidden = false
        gradeCellDivider?.isHidden = false

        guard submission.grade != nil else {
            gradeCircleBottomConstraint?.isActive = false
            submittedView?.isHidden = false
            return
        }

        gradeCircleBottomConstraint?.isActive = true
        submittedView?.isHidden = true
    }

    func update(assignment: Assignment, quiz: Quiz?, baseURL: URL?) {
        nameLabel?.text = assignment.name
        pointsLabel?.text = assignment.pointsPossibleText
        statusIconView?.isHidden = assignment.submissionStatusIsHidden
        statusIconView?.image = assignment.submissionStatusIcon
        statusIconView?.tintColor = assignment.submissionStatusColor
        statusLabel?.isHidden = assignment.submissionStatusIsHidden
        statusLabel?.textColor = assignment.submissionStatusColor
        statusLabel?.text = assignment.submissionStatusText
        dueLabel?.text = assignment.dueText
        submissionTypesLabel?.text = assignment.submissionTypeText
        fileTypesLabel?.text = assignment.fileTypeText
        fileTypesHeadingLabel?.isHidden = !assignment.hasFileTypes
        fileTypesLabel?.isHidden = !assignment.hasFileTypes
        fileTypesDivider?.isHidden = !assignment.hasFileTypes
        descriptionHeadingLabel?.text = quiz == nil
            ? NSLocalizedString("Description", bundle: .student, comment: "")
            : NSLocalizedString("Instructions", bundle: .student, comment: "")
        descriptionView?.loadHTMLString(assignment.descriptionHTML, baseURL: baseURL)
        updateGradeCell(assignment)

        submissionButtonView?.isHidden = !assignment.isSubmittable
        submissionButtonDivider?.isHidden = !assignment.isSubmittable
        updateQuizSettings(quiz)

        scrollView?.isHidden = false
        loadingView?.stopAnimating()
        refreshControl?.endRefreshing()
    }

    func updateQuizSettings(_ quiz: Quiz?) {
        guard let quiz = quiz else {
            quizView?.isHidden = true
            return
        }
        quizAttemptsValueLabel?.text = quiz.allowedAttemptsText
        quizQuestionsValueLabel?.text = quiz.questionCountText
        quizTimeLimitValueLabel?.text = quiz.timeLimitText
        quizView?.isHidden = false
    }

    func showError(_ error: Error) {
        // FIXME: Proper error handling
        assertionFailure(error.localizedDescription)
    }

    func showSubmitAssignmentButton(title: String?) {
        if let title = title {
            scrollviewInsetConstraint.constant = submitAssignmentButton.bounds.size.height + scrollViewInsetPadding
            submitAssignmentButton.setTitle(title, for: .normal)
            submitAssignmentButton.alpha = 1.0
        } else {
            scrollviewInsetConstraint.constant = 0
            submitAssignmentButton.alpha = 0
        }
    }

    func chooseSubmissionType(_ types: [SubmissionType]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // set ipad properties to display modal
        alert.popoverPresentationController?.sourceView = submitAssignmentButton?.superview
        alert.popoverPresentationController?.sourceRect =  CGRect(origin: submitAssignmentButton?.superview?.center ?? .zero, size: .zero)
        alert.popoverPresentationController?.permittedArrowDirections = []
        for type in types {
            let action = UIAlertAction(title: type.localizedString, style: .default) { _ in
                self.presenter?.submit(type, from: self)
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    func present(filePicker: FilePickerViewController) {
        filePicker.delegate = self
        let nav = UINavigationController(rootViewController: filePicker)
        present(nav, animated: true, completion: nil)
    }

    func chooseMediaRecordingType() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Record Audio", comment: ""), style: .default) { [weak self] _ in
            AudioRecorderViewController.requestPermission { allowed in
                if allowed {
                    let controller = AudioRecorderViewController.create()
                    controller.delegate = self
                    controller.view.backgroundColor = UIColor.named(.backgroundLightest)
                    self?.present(controller, animated: true, completion: nil)
                } else {
                    self?.showPermissionError(.microphone)
                }
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Record Video", comment: ""), style: .default) { _ in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            let cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = .camera
            cameraController.mediaTypes = [kUTTypeMovie as String]
            cameraController.cameraCaptureMode = .video
            self.present(cameraController, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        present(alert, animated: true, completion: nil)
    }

    func submit(mediaRecording url: URL, type: MediaCommentType) {
        let alert = UIAlertController(title: NSLocalizedString("Uploading", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { [weak self] _ in
            self?.presenter?.cancelOnlineUpload()
        })
        present(alert, animated: true) {
            self.presenter?.submit(mediaRecording: url, type: type) { [weak self] error in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        if let error = error {
                            let alert = UIAlertController(title: NSLocalizedString("Submission Failed", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default) { _ in
                                self?.submit(mediaRecording: url, type: type)
                            })
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: NSLocalizedString("Success!", comment: ""), message: nil, preferredStyle: .alert)
                            self?.present(alert, animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400)) {
                                    alert.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AssignmentDetailsViewController: AudioRecorderDelegate {
    func cancel(_ controller: AudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func send(_ controller: AudioRecorderViewController, url: URL) {
        controller.dismiss(animated: true) {
            self.submit(mediaRecording: url, type: .audio)
        }
    }
}

extension AssignmentDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            do {
                if let videoURL = info[.mediaURL] as? URL {
                    let destination = URL
                        .temporaryDirectory
                        .appendingPathComponent("videos", isDirectory: true)
                        .appendingPathComponent(String(Clock.now.timeIntervalSince1970))
                        .appendingPathExtension(videoURL.pathExtension)
                    try videoURL.move(to: destination)
                    self.submit(mediaRecording: destination, type: .video)
                }
            } catch {
                self.showError(error)
            }
        }
    }
}

extension AssignmentDetailsViewController: FilePickerControllerDelegate {
    func add(_ controller: FilePickerViewController, url: URL) {
        presenter?.addOnlineUpload(file: url)
    }

    func submit(_ controller: FilePickerViewController) {
        controller.dismiss(animated: true) {
            self.presenter?.submitOnlineUpload()
        }
    }

    func cancel(_ controller: FilePickerViewController) {
        controller.dismiss(animated: true) {
            self.presenter?.cancelOnlineUpload()
        }
    }

    func retry(_ controller: FilePickerViewController) {
        // TODO: presenter?.retryOnlineUpload()
    }

    func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return presenter?.files.isEmpty == false
    }
}

// MARK: - Events
extension AssignmentDetailsViewController {
    @IBAction func actionSubmitAssignment(_ sender: UIButton) {
        presenter?.submitAssignment(from: self)
    }

    @IBAction func didTapSubmission(_ sender: UIButton) {
        presenter?.routeToSubmission(view: self)
    }
}
