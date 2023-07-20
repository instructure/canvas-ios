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

import Foundation
import UIKit
import Core

class QuizDetailsViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol, CoreWebViewLinkDelegate {
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
    let titleSubtitleView = TitleSubtitleView.create()

    var color: UIColor?
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

    static func create(courseID: String, quizID: String) -> QuizDetailsViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.quizID = quizID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("Quiz Details", comment: ""))

        attemptsLabel.text = NSLocalizedString("Allowed Attempts:", comment: "")
        dueHeadingLabel.text = NSLocalizedString("Due", comment: "")
        instructionsHeadingLabel.text = NSLocalizedString("Instructions", comment: "")
        questionsLabel.text = NSLocalizedString("Questions:", comment: "")
        settingsHeadingLabel.text = NSLocalizedString("Settings", comment: "")
        timeLimitLabel.text = NSLocalizedString("Time Limit:", comment: "")

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

    override func viewWillAppear(_ animated: Bool) {
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
        pointsLabel.text = quiz?.pointsPossibleText
        if let finishedAt = submission?.finishedAt {
            statusIconView.image = .completeSolid
            statusIconView.tintColor = .textSuccess
            statusLabel.textColor = .textSuccess
            statusLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("Submitted %@", comment: "Submitted date"),
                finishedAt.dateTimeString
            )
        } else if submission?.attempt ?? 0 > 1 {
            statusIconView.image = .completeSolid
            statusIconView.tintColor = .textSuccess
            statusLabel.textColor = .textSuccess
            statusLabel.text = NSLocalizedString("Submitted", comment: "")
        } else {
            statusIconView.image = .noSolid
            statusIconView.tintColor = .textDark
            statusLabel.textColor = .textDark
            statusLabel.text = NSLocalizedString("Not Submitted", comment: "")
        }
        dueLabel.text = quiz?.dueText
        attemptsValueLabel.text = quiz?.allowedAttemptsText
        questionsValueLabel.text = quiz?.questionCountText
        timeLimitValueLabel.text = quiz?.timeLimitText
        instructionsHeadingLabel.text = quiz?.lockedForUser == true
            ? NSLocalizedString("Locked", comment: "")
            : NSLocalizedString("Instructions", comment: "")
        var html = quiz?.lockExplanation ?? quiz?.details ?? ""
        if html.isEmpty { html = NSLocalizedString("No Content", comment: "") }
        instructionsWebView.loadHTMLString(html, baseURL: quiz?.htmlURL)
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
                return NSLocalizedString("Take Quiz", comment: "")
            }
            if submission.canResume {
                return NSLocalizedString("Resume Quiz", comment: "")
            }
            return submission.finishedAt != nil || submission.attempt > 1
                ? NSLocalizedString("Retake Quiz", comment: "")
                : NSLocalizedString("Take Quiz", comment: "")
        } else if quiz.resultsURL != nil {
            return NSLocalizedString("View Results", comment: "")
        }
        return nil
    }

    @IBAction func take() {
        guard let quiz = quizzes.first else { return }
        if quiz.canTake {
            env.router.show(QuizWebViewController.create(
                courseID: courseID,
                quizID: quizID
            ), from: self, options: .modal(.fullScreen, isDismissable: false, embedInNav: true))
        } else if let url = quiz.resultsURL {
            env.router.route(to: url, from: self, options: .modal(embedInNav: true))
        }
    }
}
