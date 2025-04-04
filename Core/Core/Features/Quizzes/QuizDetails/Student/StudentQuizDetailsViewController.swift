//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class StudentQuizDetailsViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol, CoreWebViewLinkDelegate {
    @IBOutlet weak var attemptsLabel: UILabel!
    @IBOutlet weak var attemptsValueLabel: UILabel!
    @IBOutlet weak var dueHeadingLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var instructionsHeadingLabel: UILabel!
    @IBOutlet weak var instructionsContainer: UIView!
    let instructionsWebView = CoreWebView()
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var questionsLabel: UILabel!
    @IBOutlet weak var questionsValueLabel: UILabel!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var settingsHeadingLabel: UILabel!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var timeLimitValueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    public let titleSubtitleView = TitleSubtitleView.create()
    var offlineModeInteractor: OfflineModeInteractor?

    public var color: UIColor?
    var courseID = ""
    let env = AppEnvironment.shared
    var quizID = ""
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "courses/\(courseID)/quizzes/\(quizID)"
    )

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var quizzes = env.subscribe(GetQuiz(courseID: courseID, quizID: quizID)) { [weak self] in
        self?.update()
    }

    public static func create(
        courseID: String,
        quizID: String,
        offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()) -> StudentQuizDetailsViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.quizID = quizID
        controller.offlineModeInteractor = offlineModeInteractor
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: String(localized: "Quiz Details", bundle: .core))

        attemptsLabel.text = String(localized: "Allowed Attempts:", bundle: .core)
        dueHeadingLabel.text = String(localized: "Due", bundle: .core)
        instructionsHeadingLabel.text = String(localized: "Instructions", bundle: .core)
        questionsLabel.text = String(localized: "Questions:", bundle: .core)
        settingsHeadingLabel.text = String(localized: "Settings", bundle: .core)
        timeLimitLabel.text = String(localized: "Time Limit:", bundle: .core)

        instructionsContainer.addSubview(instructionsWebView)
        instructionsWebView.pinWithThemeSwitchButton(inside: instructionsContainer)
        instructionsWebView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        instructionsWebView.autoresizesHeight = true
        instructionsWebView.scrollView.showsVerticalScrollIndicator = false
        instructionsWebView.scrollView.alwaysBounceVertical = false
        instructionsWebView.backgroundColor = .backgroundLightest
        instructionsWebView.linkDelegate = self

        loadingView.color = nil
        refreshControl.color = nil
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl
        scrollView.isHidden = true
        takeButton.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .quizRefresh, object: nil)

        colors.refresh()
        courses.refresh()
        // We need to force refresh because the list deletes (& kills the submission association)
        quizzes.refresh(force: true)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    @objc func refresh() {
        colors.refresh(force: true)
        courses.refresh(force: true)
        quizzes.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    func updateNavBar() {
        guard let course = courses.first, !colors.pending else { return }
        updateNavBar(subtitle: course.name, color: course.color)
        view.tintColor = color
    }

    func update() {
        let quiz = quizzes.first
        let submission = quiz?.submission
        loadingView.isHidden = quizzes.error != nil || !quizzes.pending || !quizzes.isEmpty || refreshControl.isRefreshing
        titleLabel.text = quiz?.title
        pointsLabel.text = quiz?.hideQuantitativeData == true ? nil : quiz?.pointsPossibleText
        if let finishedAt = submission?.finishedAt {
            statusIconView.image = .completeSolid
            statusIconView.tintColor = .textSuccess
            statusLabel.textColor = .textSuccess
            statusLabel.text = String.localizedStringWithFormat(
                String(localized: "Submitted %@", bundle: .core, comment: "Submitted date"),
                finishedAt.dateTimeString
            )
        } else if submission?.attempt ?? 0 > 1 {
            statusIconView.image = .completeSolid
            statusIconView.tintColor = .textSuccess
            statusLabel.textColor = .textSuccess
            statusLabel.text = String(localized: "Submitted", bundle: .core)
        } else {
            statusIconView.image = .noSolid
            statusIconView.tintColor = .textDark
            statusLabel.textColor = .textDark
            statusLabel.text = String(localized: "Not Submitted", bundle: .core)
        }
        dueLabel.text = quiz?.dueText
        attemptsValueLabel.text = quiz?.allowedAttemptsText
        questionsValueLabel.text = quiz?.questionCountText
        timeLimitValueLabel.text = quiz?.timeLimitText
        instructionsHeadingLabel.text = quiz?.lockedForUser == true
            ? String(localized: "Locked", bundle: .core)
            : String(localized: "Instructions", bundle: .core)
        var html = quiz?.lockExplanation ?? quiz?.details ?? ""
        if html.isEmpty { html = String(localized: "No Content", bundle: .core) }

        let offlinePath = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: env.currentSession?.uniqueID ?? "",
            courseId: courses.first?.id ?? "",
            sectionName: OfflineFolderPrefix.quizzes.rawValue,
            resourceId: quizID
        ).appendingPathComponent("body.html")
        instructionsWebView.loadContent(
            isOffline: offlineModeInteractor?.isNetworkOffline(),
            filePath: offlinePath,
            content: html,
            originalBaseURL: quiz?.htmlURL
        )

        scrollView.isHidden = quiz == nil
        let title = takeButtonTitle
        takeButton.setTitle(title, for: .normal)
        takeButton.isHidden = title == nil
        takeButton.makeUnavailableInOfflineMode()

        if courses.requested && !courses.pending && quizzes.requested && !quizzes.pending && colors.requested && !colors.pending {
            UIAccessibility.post(notification: .screenChanged, argument: view)
        }
    }

    var takeButtonTitle: String? {
        guard let quiz = quizzes.first, !quizzes.pending else { return nil }
        if quiz.canTake {
            guard let submission = quiz.submission else {
                return String(localized: "Take Quiz", bundle: .core)
            }
            if submission.canResume {
                return String(localized: "Resume Quiz", bundle: .core)
            }
            return submission.finishedAt != nil || submission.attempt > 1
                ? String(localized: "Retake Quiz", bundle: .core)
                : String(localized: "Take Quiz", bundle: .core)
        } else if quiz.resultsURL != nil {
            return String(localized: "View Results", bundle: .core)
        }
        return nil
    }

    @IBAction func take() {
        guard let quiz = quizzes.first else { return }
        if quiz.canTake {
            env.router.show(StudentQuizWebViewController.create(
                courseID: courseID,
                quizID: quizID
            ), from: self, options: .modal(.fullScreen, isDismissable: false, embedInNav: true))
        } else if let url = quiz.resultsURL {
            env.router.route(to: url, from: self, options: .modal(embedInNav: true))
        }
    }
}
