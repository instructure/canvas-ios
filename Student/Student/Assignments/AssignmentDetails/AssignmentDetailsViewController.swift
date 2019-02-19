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

protocol AssignmentDetailsViewModel: DueViewable, GradeViewable, SubmissionViewable {
    var details: String? { get }
    var htmlURL: URL { get }
    var name: String { get }
}

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
    @IBOutlet weak var submissionButton: UIButton?
    @IBOutlet weak var submissionButtonLabel: DynamicLabel?
    @IBOutlet weak var submissionButtonIcon: UIImageView?
    @IBOutlet weak var submissionButtonDivider: DividerView?
    @IBOutlet weak var fileSubmissionButton: DynamicButton?

    var refreshControl: UIRefreshControl?
    @IBOutlet weak var gradeCell: UIView?
    @IBOutlet weak var gradeCellDivider: DividerView?
    @IBOutlet weak var gradedView: UIView?
    @IBOutlet weak var circlePoints: UILabel?
    @IBOutlet weak var circleLabel: UILabel?
    @IBOutlet weak var circleComplete: UIImageView?
    @IBOutlet weak var gradeCircle: GradeCircle?
    @IBOutlet weak var gradeCircleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayGrade: UILabel?
    @IBOutlet weak var outOfLabel: UILabel?
    @IBOutlet weak var latePenaltyLabel: UILabel?
    @IBOutlet weak var finalGradeLabel: UILabel?
    @IBOutlet weak var submittedView: UIView?
    @IBOutlet weak var submittedLabel: UILabel?
    @IBOutlet weak var submittedDetailsLabel: UILabel?
    @IBOutlet weak var submitAssignmentButton: DynamicButton!
    @IBOutlet weak var scrollviewInsetConstraint: NSLayoutConstraint!
    let scrollViewInsetPadding: CGFloat = 24.0

    let titleSubtitleView = TitleSubtitleView.create()
    var presenter: AssignmentDetailsPresenter?

    static func create(env: AppEnvironment = .shared, courseID: String, assignmentID: String, fragment: String? = nil) -> AssignmentDetailsViewController {
        let controller = Bundle.loadController(self)
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
        submittedLabel?.text = NSLocalizedString("Successfully submitted!", bundle: .student, comment: "")
        submittedDetailsLabel?.text = NSLocalizedString("Your submission is now waiting to be graded", bundle: .student, comment: "")
        submissionButtonLabel?.text = NSLocalizedString("Submission & Rubric", bundle: .student, comment: "")

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc
    func refresh(_ refreshControl: UIRefreshControl) {
        presenter?.loadDataFromServer()
    }

    @objc
    func debugExit() {
        exit(EXIT_SUCCESS)
    }

    @IBAction
    func viewFileSubmission() {
        presenter?.viewFileSubmission(from: self)
    }

    func updateNavBar(subtitle: String?, backgroundColor: UIColor?) {
        titleSubtitleView.subtitle = subtitle
        navigationController?.navigationBar.useContextColor(backgroundColor)
    }

    func hideGradeCell() {
        gradeCell?.isHidden = true
        gradeCellDivider?.isHidden = true
    }

    func updateGradeCell(_ assignment: AssignmentDetailsViewModel) {
        // in this case the submission should always be there because canvas generates
        // submissions for every user for every assignment but just in case
        guard let submission = assignment.submission else {
            hideGradeCell()
            return
        }

        submittedLabel?.textColor = UIColor.named(.textSuccess).ensureContrast(against: .white)

        if assignment.showFileSubmissionStatus {
            gradeCell?.isHidden = false
            gradeCellDivider?.isHidden = false
            gradedView?.isHidden = true
            submittedView?.isHidden = false
            fileSubmissionButton?.isHidden = false
            submittedDetailsLabel?.isHidden = true
            submittedLabel?.text = assignment.fileSubmissionStatusText
            submittedLabel?.textColor = assignment.fileSubmissionStatusTextColor
            fileSubmissionButton?.setTitle(assignment.fileSubmissionButtonText, for: .normal)
            return
        }

        guard submission.workflowState != .unsubmitted else {
            hideGradeCell()
            return
        }

        gradeCell?.isHidden = false
        gradeCellDivider?.isHidden = false

        guard submission.grade != nil else {
            gradedView?.isHidden = true
            gradeCircleBottomConstraint?.isActive = false
            submittedView?.isHidden = false
            return
        }

        gradedView?.isHidden = false
        gradeCircleBottomConstraint?.isActive = true
        submittedView?.isHidden = true

        if assignment.gradingType == .pass_fail {
            circlePoints?.isHidden = true
            circleLabel?.isHidden = true
            circleComplete?.isHidden = false

            circleComplete?.isHidden = submission.score == nil || submission.score == 0
        } else {
            circlePoints?.isHidden = false
            circleLabel?.isHidden = false
            circleComplete?.isHidden = true
        }

        // Update grade circle
        if let score = submission.score, let pointsPossible = assignment.pointsPossible {
            circlePoints?.text = NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
            gradeCircle?.progress = score / pointsPossible

            gradeCircle?.accessibilityLabel = assignment.scoreOutOfPointsPossibleText
        }

        circleLabel?.text = assignment.pointsText

        // Update the display grade
        displayGrade?.isHidden = assignment.gradingType == .points || submission.late == true
        displayGrade?.text = assignment.gradeText

        // Update the outOf label
        outOfLabel?.text = assignment.outOfText

        // Update the Late penalty and Final Grade
        latePenaltyLabel?.isHidden = true
        finalGradeLabel?.isHidden = true
        if assignment.hasLatePenalty {
            latePenaltyLabel?.isHidden = false
            finalGradeLabel?.isHidden = false

            latePenaltyLabel?.text = assignment.latePenaltyText
            finalGradeLabel?.text = assignment.finalGradeText
        }
    }

    func update(assignment: AssignmentDetailsViewModel, baseURL: URL?) {
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
        descriptionView?.loadHTMLString(
            assignment.details ?? NSLocalizedString("No Content", bundle: .student, comment: ""),
            baseURL: baseURL
        )
        updateGradeCell(assignment)

        submissionButtonView?.isHidden = !assignment.isSubmittable
        submissionButtonDivider?.isHidden = !assignment.isSubmittable

        scrollView?.isHidden = false
        loadingView?.stopAnimating()
        refreshControl?.endRefreshing()
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
