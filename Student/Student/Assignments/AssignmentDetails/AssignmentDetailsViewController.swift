//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Core
import SwiftUI
import UIKit

class AssignmentDetailsViewController: ScreenViewTrackableViewController, AssignmentDetailsViewProtocol {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var pointsLabel: UILabel?
    @IBOutlet weak var statusIconView: UIImageView?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var attemptPickerSection: UIView?
    @IBOutlet weak var attemptLabel: UILabel?
    @IBOutlet weak var attemptDateButton: DynamicButton!
    @IBOutlet weak var gradeHeadingLabel: UILabel?
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var submissionButton: DynamicButton! {
        didSet {
            var buttonConfig = UIButton.Configuration.plain()
            buttonConfig.imagePlacement = .trailing
            buttonConfig.imagePadding = 4
            buttonConfig.image = .arrowOpenRightSolid
                .scaleTo(.init(width: 14, height: 14))
                .withRenderingMode(.alwaysTemplate)
            buttonConfig.contentInsets = {
                var result = buttonConfig.contentInsets
                result.trailing = 0
                return result
            }()
            buttonConfig.titleTextAttributesTransformer = .init { attributes in
                var result = attributes
                result.font = UIFont.scaledNamedFont(.regular16)
                return result
            }
            submissionButton?.configuration = buttonConfig
        }
    }
    @IBOutlet weak var fileSubmissionButton: DynamicButton?

    /** Container for the description title and the divider above it */
    @IBOutlet weak var descriptionHeader: UIView?
    @IBOutlet weak var descriptionHeadingLabel: UILabel?
    @IBOutlet weak var descriptionView: UIView?

    @IBOutlet weak var gradedView: GradeCircleView?
    @IBOutlet weak var gradeStatisticGraphView: GradeStatisticGraphView?
    @IBOutlet weak var submittedView: UIView?
    @IBOutlet weak var submittedLabel: UILabel?
    @IBOutlet weak var submittedDetailsLabel: UILabel?
    @IBOutlet weak var submittedIcon: UIImageView?
    @IBOutlet private var submittedIconHiddenConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var submitAssignmentButton: DynamicButton!

    @IBOutlet weak var quizAttemptsLabel: UILabel?
    @IBOutlet weak var quizAttemptsValueLabel: UILabel?
    @IBOutlet weak var quizHeadingLabel: UILabel?
    @IBOutlet weak var quizQuestionsLabel: UILabel?
    @IBOutlet weak var quizQuestionsValueLabel: UILabel?
    @IBOutlet weak var quizTimeLimitLabel: UILabel?
    @IBOutlet weak var quizTimeLimitValueLabel: UILabel?
    @IBOutlet weak var quizView: UIView?

    @IBOutlet weak var lockedSection: UIView?
    @IBOutlet weak var gradeSection: UIStackView?
    @IBOutlet weak var gradeSectionBottomSpacer: UIView?
    @IBOutlet weak var fileTypesSection: AssignmentDetailsSectionContainerView?
    @IBOutlet weak var submissionTypesSection: AssignmentDetailsSectionContainerView?
    @IBOutlet weak var dueSection: AssignmentDetailsSectionContainerView?

    @IBOutlet weak var lockedIconContainerView: UIView!
    @IBOutlet weak var lockedIconImageView: UIImageView!
    @IBOutlet weak var lockedIconHeight: NSLayoutConstraint!
    @IBOutlet weak var lockedSubheaderWebView: CoreWebView!
    @IBOutlet weak var lockedSectionHeader: DynamicLabel!

    @IBOutlet weak var attemptsHeadingLabel: UILabel!
    @IBOutlet weak var attemptsAllowedLabel: UILabel!
    @IBOutlet weak var attemptsAllowedValueLabel: UILabel!
    @IBOutlet weak var attemptsUsedLabel: UILabel!
    @IBOutlet weak var attemptsUsedValueLabel: UILabel!
    @IBOutlet weak var attemptsView: UIView!

    //  Note to developer adding new views:
    //  If any new views are added, make sure they are properly hidden/shown
    //  when assignment is locked in the various lockStatus states

    var assignmentID = ""
    var courseID = ""
    let env = AppEnvironment.shared
    var fragment: String?
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/courses/\(courseID)/assignments/\(assignmentID)"
    )
    var refreshControl: CircleRefreshControl?
    let titleSubtitleView = TitleSubtitleView.create()
    var presenter: AssignmentDetailsPresenter?
    private let webView = CoreWebView()
    private let isLeftToRightLayout: Bool = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
    private weak var gradeBorderLayer: CAShapeLayer?
    private var offlineModeInteractor: OfflineModeInteractor?
    private var gradeSectionBoundsObservation: NSKeyValueObservation?
    private var remindersInteractor = AssignmentRemindersInteractorLive()

    static func create(courseID: String,
                       assignmentID: String,
                       fragment: String? = nil,
                       offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()
    ) -> AssignmentDetailsViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.courseID = courseID
        controller.fragment = fragment
        controller.presenter = AssignmentDetailsPresenter(view: controller, courseID: courseID, assignmentID: assignmentID, fragment: fragment)
        controller.offlineModeInteractor = offlineModeInteractor
        return controller
    }

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        // Navigation Bar
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = NSLocalizedString("Assignment Details", bundle: .student, comment: "")

        // Loading
        scrollView?.isHidden = true
        scrollView?.backgroundColor = .backgroundLightest
        loadingView.color = Brand.shared.primary
        loadingView.startAnimating()
        let refreshControl = CircleRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        scrollView?.addSubview(refreshControl)
        self.refreshControl = refreshControl
        showSubmitAssignmentButton(title: nil)

        // Accessibility
        dueSection?.subHeader.accessibilityIdentifier = "AssignmentDetails.due"
        fileTypesSection?.subHeader.accessibilityIdentifier = "AssignmentDetails.allowedExtensions"
        submissionTypesSection?.subHeader.accessibilityIdentifier = "AssignmentDetails.submissionTypes"

        // Localization
        dueSection?.header.text = NSLocalizedString("Due", bundle: .student, comment: "")
        submissionTypesSection?.header.text = NSLocalizedString("Submission Types", bundle: .student, comment: "")
        fileTypesSection?.header.text = NSLocalizedString("File Types", bundle: .student, comment: "")
        gradeHeadingLabel?.text = NSLocalizedString("Grade", bundle: .student, comment: "")
        descriptionHeadingLabel?.text = NSLocalizedString("Description", bundle: .student, comment: "")
        quizAttemptsLabel?.text = NSLocalizedString("Allowed Attempts:", bundle: .student, comment: "")
        quizHeadingLabel?.text = NSLocalizedString("Settings", bundle: .student, comment: "")
        quizQuestionsLabel?.text = NSLocalizedString("Questions:", bundle: .student, comment: "")
        quizTimeLimitLabel?.text = NSLocalizedString("Time Limit:", bundle: .student, comment: "")
        submittedLabel?.text = NSLocalizedString("Successfully submitted!", bundle: .student, comment: "")
        submittedDetailsLabel?.text = NSLocalizedString("Your submission is now waiting to be graded.", bundle: .student, comment: "")
        submissionButton?.setTitle(NSLocalizedString("Submission & Rubric", bundle: .student, comment: ""), for: .normal)
        attemptsHeadingLabel.text = NSLocalizedString("Attempts", comment: "")
        attemptsAllowedLabel.text = NSLocalizedString("Attempts Allowed:", comment: "")
        attemptsUsedLabel.text = NSLocalizedString("Attempts Used:", comment: "")
        attemptsAllowedValueLabel.text = nil
        attemptsUsedValueLabel.text = nil

        //  locked
        lockedIconImageView.image = UIImage(named: Panda.Locked.name, in: .core, compatibleWith: nil)

        // Routing from description
        webView.linkDelegate = self
        webView.autoresizesHeight = true
        webView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        descriptionView?.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: descriptionView)

        let tapGradedView = UITapGestureRecognizer(target: self, action: #selector(didTapSubmission(_:)))
        gradedView?.addGestureRecognizer(tapGradedView)

        submitAssignmentButton.makeUnavailableInOfflineMode()
        fileSubmissionButton?.makeUnavailableInOfflineMode()
        submissionButton?.makeUnavailableInOfflineMode()

        embedReminderSection()

        let border = CAShapeLayer()
        border.strokeColor = UIColor.borderDark.cgColor
        border.lineWidth = 0.5
        border.fillColor = nil
        gradeSection?.layer.addSublayer(border)
        // Since rounded corners are rendered 1 cycle after the view has been rendered
        // we draw a regular border so only the rendering of the rounding will lag behind
        // and not the whole border
        gradeSection?.layer.borderColor = UIColor.borderDark.cgColor
        gradeSection?.layer.borderWidth = 0.5
        gradeBorderLayer = border

        submittedIcon?.image = .completeLine.withRenderingMode(.alwaysTemplate)
        submittedIcon?.tintColor = .textDarkest

        gradeSectionBoundsObservation = gradeSection?.observe(\.bounds) { [weak gradeBorderLayer] gradeSection, _ in
            gradeBorderLayer?.frame = gradeSection.bounds
            gradeBorderLayer?.path = UIBezierPath(roundedRect: gradeSection.bounds,
                                                  cornerRadius: 6).cgPath
            // Remove the placeholder border
            gradeSection.layer.borderColor = nil
            gradeSection.layer.borderWidth = 0
        }
        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(presenter?.courses.first?.color)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppStoreReview.handleNavigateToAssignment()
    }

    deinit {
        AppStoreReview.handleNavigateFromAssignment()
    }

    @objc
    func refresh(_ refreshControl: CircleRefreshControl) {
        presenter?.refresh()
    }

    @IBAction
    func viewFileSubmission() {
        presenter?.viewFileSubmission()
    }

    func updateNavBar(subtitle: String?, backgroundColor: UIColor?) {
        titleSubtitleView.subtitle = subtitle
        navigationController?.navigationBar.useContextColor(backgroundColor)
    }

    func updateGradeCell(_ assignment: Assignment, submission: Submission?) {
        self.gradedView?.update(assignment, submission: submission, circleColor: presenter?.courses.first?.color)

        // Update grade statistics view
        if let presenter = presenter {
            let shouldHide = presenter.statisticsIsHidden()
            self.gradeStatisticGraphView?.isHidden = shouldHide
            if !shouldHide {
                self.gradeStatisticGraphView?.update(assignment)
            }
        }

        // in this case the submission should always be there because canvas generates
        // submissions for every user for every assignment but just in case
        guard let submission else {
            hideGradeCell()
            return
        }

        submittedLabel?.textColor = .textDarkest
        submittedLabel?.text = NSLocalizedString("Successfully submitted!", bundle: .student, comment: "")
        submittedDetailsLabel?.isHidden = false
        changeSubmittedIconVisibility(to: true)

        fileSubmissionButton?.isHidden = true

        if submission.excused == true {
            // Excused assignments cannot be submitted so we make sure not to
            // reserve any space for the not visible submit button below the scroll
            showSubmitAssignmentButton(title: nil)
            return
        }

        if let onlineUploadState = presenter?.onlineUploadState {
            gradeSection?.isHidden = false
            gradeSectionBottomSpacer?.isHidden = false
            gradedView?.isHidden = true
            submittedView?.isHidden = false
            fileSubmissionButton?.isHidden = false
            submittedDetailsLabel?.isHidden = true
            updateSubmissionLabels(state: onlineUploadState)
        }

        if submission.workflowState == .unsubmitted {
            hideGradeCell()
            return
        }

        if submission.needsGrading, submission.score == nil {
            submittedView?.isHidden = false
            return
        }

        submittedView?.isHidden = presenter?.onlineUploadState == nil
    }

    func updateSubmissionLabels(state: OnlineUploadState) {
        switch state {
        case .reSubmissionFailed:
            submittedLabel?.text = NSLocalizedString("Resubmission Failed", bundle: .core, comment: "")
            submittedLabel?.textColor = UIColor.textDanger.ensureContrast(against: .white)
            submittedDetailsLabel?.isHidden = true
            fileSubmissionButton?.setTitle(NSLocalizedString("Tap to view details", bundle: .core, comment: ""), for: .normal)
            changeSubmittedIconVisibility(to: false)
            return
        case .failed:
            submittedLabel?.text = NSLocalizedString("Submission Failed", bundle: .core, comment: "")
            submittedLabel?.textColor = UIColor.textDanger.ensureContrast(against: .white)
            submittedDetailsLabel?.isHidden = true
            fileSubmissionButton?.setTitle(NSLocalizedString("Tap to view details", bundle: .core, comment: ""), for: .normal)
            changeSubmittedIconVisibility(to: false)
            return
        case .uploading:
            submittedLabel?.text = NSLocalizedString("Submission Uploading...", bundle: .core, comment: "")
            submittedLabel?.textColor = .textDarkest
            submittedDetailsLabel?.isHidden = true
            fileSubmissionButton?.setTitle(NSLocalizedString("Tap to view progress", bundle: .core, comment: ""), for: .normal)
            changeSubmittedIconVisibility(to: false)
            return
        case .staged:
            submittedLabel?.text = NSLocalizedString("Submission In Progress...", bundle: .core, comment: "")
            submittedLabel?.textColor = .textDarkest
            submittedDetailsLabel?.isHidden = true
            fileSubmissionButton?.setTitle(NSLocalizedString("Tap to view progress", bundle: .core, comment: ""), for: .normal)
            changeSubmittedIconVisibility(to: false)
            return
        case .completed:
            fileSubmissionButton?.isHidden = true
            if let nav = presentedViewController as? UINavigationController, let filePicker = nav.viewControllers.first as? FilePickerViewController {
                filePicker.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func changeSubmittedIconVisibility(to visible: Bool) {
        submittedIconHiddenConstraints.forEach { $0.isActive = !visible }
    }

    func update(assignment: Assignment, quiz: Quiz?, submission: Submission?, baseURL: URL?) {
        let hideScores = assignment.hideQuantitativeData
        nameLabel?.text = assignment.name
        pointsLabel?.text = hideScores ? nil : assignment.pointsPossibleText
        pointsLabel?.isHidden = pointsLabel?.text == nil
        statusIconView?.isHidden = assignment.submissionStatusIsHidden
        statusIconView?.image = assignment.submissionStatusIcon
        statusIconView?.tintColor = assignment.submissionStatusColor
        statusLabel?.isHidden = assignment.submissionStatusIsHidden
        statusLabel?.textColor = assignment.submissionStatusColor
        statusLabel?.text = assignment.submissionStatusText
        dueSection?.subHeader.text = assignment.dueAt.flatMap {
            $0.dateTimeString
        } ?? NSLocalizedString("No Due Date", bundle: .core, comment: "")
        submissionTypesSection?.subHeader.text = assignment.submissionTypeText
        fileTypesSection?.subHeader.text = assignment.fileTypeText
        fileTypesSection?.isHidden = !assignment.hasFileTypes
        attemptsAllowedValueLabel.text = assignment.allowedAttempts > 0
            ? NumberFormatter.localizedString(from: NSNumber(value: assignment.allowedAttempts), number: .none)
            : NSLocalizedString("Unlimited", comment: "")
        attemptsUsedValueLabel.text = NumberFormatter.localizedString(from: NSNumber(value: assignment.usedAttempts), number: .none)
        descriptionHeadingLabel?.text = quiz == nil
            ? NSLocalizedString("Description", bundle: .student, comment: "")
            : NSLocalizedString("Instructions", bundle: .student, comment: "")
        webView.loadHTMLString(presenter?.assignmentDescription() ?? "", baseURL: baseURL)
        updateGradeCell(assignment, submission: submission)

        guard let presenter = presenter else { return }

        lockedIconContainerView.isHidden = presenter.lockedIconContainerViewIsHidden()
        dueSection?.isHidden = presenter.dueSectionIsHidden()
        lockedSection?.isHidden = presenter.lockedSectionIsHidden()
        fileTypesSection?.isHidden = presenter.fileTypesSectionIsHidden()
        submissionTypesSection?.isHidden = presenter.submissionTypesSectionIsHidden()
        var showGradeSection = assignment.submission?.needsGrading == true ||
            (assignment.submission?.isGraded == true  && assignment.gradingType != .not_graded ) ||
            presenter.onlineUploadState != nil
        let gradeText = GradeFormatter.string(from: assignment, style: .short)
        if assignment.hideQuantitativeData, (gradeText ?? "").isEmpty == true {
            showGradeSection = false
        }

        attemptsView.isHidden = presenter.attemptsIsHidden()
        gradeSection?.isHidden = !showGradeSection
        gradeSectionBottomSpacer?.isHidden = !showGradeSection
        submissionButton?.isHidden = presenter.viewSubmissionButtonSectionIsHidden()
        showDescription(!presenter.descriptionIsHidden())

        submitAssignmentButton.isHidden = presenter.submitAssignmentButtonIsHidden()

        lockedSubheaderWebView.loadHTMLString(presenter.lockExplanation)
        centerLockedIconContainerView()

        updateQuizSettings(quiz)
        remindersInteractor.assignmentDidUpdate.send(assignment)

        scrollView?.isHidden = false
        loadingView.stopAnimating()
        refreshControl?.endRefreshing()
        UIAccessibility.post(notification: .screenChanged, argument: view)
    }

    func updateAttemptInfo(attemptNumber: String) {
        attemptLabel?.text = attemptNumber
    }

    func updateAttemptPickerButton(isActive: Bool,
                                   attemptDate: String,
                                   items: [UIAction]) {
        attemptDateButton.isEnabled = isActive
        attemptDateButton.setTitle(attemptDate, for: .normal)

        // Since submissions can't be deleted we don't have to handle the case of
        // turning the active picker to inactive
        if isActive {
            var buttonConfig = UIButton.Configuration.plain()
            buttonConfig.imagePlacement = .trailing
            buttonConfig.imagePadding = 6
            buttonConfig.image = .arrowOpenDownSolid
                .scaleTo(.init(width: 14, height: 14))
                .withRenderingMode(.alwaysTemplate)
            buttonConfig.contentInsets = {
                var result = buttonConfig.contentInsets
                result.trailing = 0
                return result
            }()
            if #available(iOS 16.0, *) {
                buttonConfig.indicator = .none
            }
            buttonConfig.titleTextAttributesTransformer = .init { attributes in
                var result = attributes
                result.font = UIFont.scaledNamedFont(.regular14)
                return result
            }
            attemptDateButton?.configuration = buttonConfig

            attemptDateButton.changesSelectionAsPrimaryAction = true
            attemptDateButton.showsMenuAsPrimaryAction = true
            attemptDateButton.menu = UIMenu(children: items)
        }
    }

    func centerLockedIconContainerView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(centerLockedIconContainerDelayedStart), object: nil)
        self.perform(#selector(centerLockedIconContainerDelayedStart), with: nil, afterDelay: 0.2)
    }

    @objc func centerLockedIconContainerDelayedStart() {
        let minIconHeight: CGFloat = 144.0
        let svContent = scrollView?.contentSize ?? CGSize.zero
        if svContent != CGSize.zero {
            let svFrame = scrollView?.frame ?? CGRect.zero
            let originInSV = lockedIconContainerView.superview?.convert(lockedIconContainerView.frame, to: scrollView) ?? CGRect.zero
            let height = (svFrame.size.height - originInSV.origin.y) - submitAssignmentButton.bounds.size.height
            lockedIconHeight.constant = max( height, minIconHeight )
            UIView.animate(withDuration: 0.08) {
                self.lockedIconContainerView?.layoutIfNeeded()
                self.lockedIconContainerView.alpha = 1.0
            }
        }
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

    func showSubmitAssignmentButton(title: String?) {
        view.bringSubviewToFront(submitAssignmentButton)
        submitAssignmentButton.setTitle(title, for: .normal)

        if title == nil {
            scrollViewBottom.constant = 0
            submitAssignmentButton.alpha = 0
        } else {
            scrollViewBottom.constant = -submitAssignmentButton.bounds.size.height
            submitAssignmentButton.alpha = OfflineModeAssembly.make().isOfflineModeEnabled() ? UIButton.DisabledInOfflineAlpha : 1.0
        }
    }

    private func embedReminderSection() {
        guard let dueSection,
              let parentStackView = dueSection.superview as? UIStackView,
              let dueSectionIndex = parentStackView.subviews.firstIndex(of: dueSection)
        else {
            return
        }

        let reminderSection = AssignmentRemindersAssembly.makeRemindersSectionController(interactor: remindersInteractor)
        addChild(reminderSection)
        parentStackView.insertArrangedSubview(reminderSection.view, at: dueSectionIndex + 1)
        reminderSection.didMove(toParent: self)
    }

    // MARK: - Show / Hide Sections

    func showDescription(_ show: Bool = true) {
        descriptionView?.isHidden = !show
        descriptionHeader?.isHidden = !show
    }

    func hideGradeCell() {
        attemptPickerSection?.isHidden = true
        gradeSection?.isHidden = true
        gradeSectionBottomSpacer?.isHidden = true
    }
}

// MARK: - Link Handling

extension AssignmentDetailsViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        guard let presenter = presenter else { return false }
        return presenter.route(to: url, from: self)
    }
}

// MARK: - Events
extension AssignmentDetailsViewController {
    @IBAction func actionSubmitAssignment(_ sender: UIButton) {
        presenter?.submit(button: sender)
    }

    @IBAction func didTapSubmission(_ sender: UIButton) {
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            UIAlertController.showItemNotAvailableInOfflineAlert()
        } else {
            presenter?.routeToSubmission(view: self)
        }
    }
}
