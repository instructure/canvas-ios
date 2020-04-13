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
import Cartography
import Core

open class QuizIntroViewController: UIViewController, PageViewEventViewControllerLoggingProtocol {
    
    // This class controls what pages are visible initially to the user
    // Based on the quiz setup, possible pages are:
    // 1. Quiz Description (always at least this page)
    // 2. Timed Quiz info
    // 3. Final answers - for 1 at a time quizes
    // *4. Maybe one for multiple attempts?
    
    let quizController: QuizController
    var takeabilityController: QuizTakeabilityController? {
        didSet {
            self.takeabilityController?.takeabilityUpdated = { [weak self] _ in
                DispatchQueue.main.async {
                    self?.takeabilityUpdated()
                }
            }
        }
    }
    @objc var takeabilityTimer: Timer?
    
    fileprivate var pages: [UIViewController] = []
    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    fileprivate let footerView: QuizIntroFooterView = QuizIntroFooterView()

    fileprivate var didShowOfflineAlert = false
    
    init(quizController: QuizController) {
        self.quizController = quizController
        super.init(nibName: nil, bundle: nil)
        
        self.quizController.quizUpdated = { [weak self] result in
            if let quiz = result.value?.content {
                self?.takeabilityController = QuizTakeabilityController(quiz: quiz, service: quizController.service)
                self?.takeabilityController?.refreshTakeability()
            } else {
                let bundle = Bundle.core
                let title = NSLocalizedString("Error Loading Quiz", tableName: "Localizable", bundle: bundle, value: "", comment: "Title for quiz loading error")
                let message = NSLocalizedString("Please check your network connection and try again.", tableName: "Localizable", bundle: bundle, value: "", comment: "")
                let buttonTitle = NSLocalizedString("Dismiss", tableName: "Localizable", bundle: bundle, value: "", comment: "Dismiss button for error alert")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            
            self?.quizUpdated()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.takeabilityController?.refreshTakeability()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.takeabilityTimer?.invalidate()
        self.takeabilityTimer = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Quiz Details", bundle: .core, comment: "")
        preparePageViewController()
        prepareFooterView()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didShowOfflineAlert = false
        quizController.refreshQuiz()
        takeabilityController?.refreshTakeability()
        startTrackingTimeOnViewController()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: quizController.service.pageViewName())
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // who cares?
        }, completion: { _ in
            let currentPage = self.footerView.pageControl.currentPage
            guard currentPage < self.pages.count else { return }
            
            let vc = self.pages[self.footerView.pageControl.currentPage]
            self.pageViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        })
    }
    
    fileprivate func preparePageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor.white
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        constrain(view, pageViewController.view) { view, pageView in
            pageView.size == view.size
            pageView.center == view.center
        }

        pages = [buildQuizDetailsPage()]
        pageViewController.setViewControllers(pages, direction: .forward, animated: false, completion: nil)

    }
    
    fileprivate func prepareFooterView() {
        view.addSubview(footerView)
        constrain(view, footerView) { view, footerView in
            footerView.left == view.left
            footerView.right == view.right
            footerView.height == 60
        }

        footerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        footerView.takeButton.addTarget(self, action: #selector(QuizIntroViewController.takeTheQuiz(_:)), for: .touchUpInside)
    }
    
    fileprivate func buildQuizDetailsPage() -> QuizDetailsViewController {
        let vc = QuizDetailsViewController(quiz: self.quizController.quiz, baseURL: self.quizController.service.baseURL)
        return vc
    }
    
    fileprivate func buildAnswersFinalPage() -> AnswersFinalViewController {
        return AnswersFinalViewController(nibName: "AnswersFinalViewController", bundle: Bundle(for: QuizIntroViewController.self))
    }
    
    fileprivate func buildTimedQuizPage() -> TimedQuizViewController {
        let vc = TimedQuizViewController(nibName: "TimedQuizViewController", bundle: Bundle(for: QuizIntroViewController.self))
        let _ = vc.view // force the hooking up of the outlet
        return vc
    }
    
    fileprivate func updateTakeButtonAndPages() {
        if pages.count == 1 {
            footerView.pageControl.isHidden = true
            footerView.setTakeButtonOnscreen(true, animated: true)
        } else {
            footerView.pageControl.isHidden = false
            footerView.setTakeButtonOnscreen(false, animated: true)
        }
        
        footerView.pageControl.currentPage = 0
        footerView.pageControl.numberOfPages = pages.count
    }
    
    fileprivate func quizUpdated() {
        // This is a very pared down implementation making a lot of assumptions.
        // Assumptions being, that this updated block would only be called once after fetching the quiz,
        // and not continously in a reactive stream style.
        
        // this stuff is just for precaution, incase you didn't see the above note and it started doing some funky stuff
        if pages.count > 1 {
            pages.removeSubrange(1...(pages.count-1))
        }
        pageViewController.setViewControllers(pages, direction: .forward, animated: false, completion: nil)
        
        let detailsPage = pages[0] as! QuizDetailsViewController
        detailsPage.quizController = quizController

        if quizController.quiz != nil {
            if quizController.quiz!.oneQuestionAtATime && quizController.quiz!.cantGoBack {
                pages.append(buildAnswersFinalPage())
            }
            switch quizController.quiz!.timeLimit {
            case .minutes(let minutes):
                let extraTime = quizController.submission?.extraTime ?? 0
                let page = buildTimedQuizPage()
                page.minuteLimit = minutes + extraTime
                pages.append(page)
            default: break
            }
        }
        
        updateTakeButtonAndPages()

        if let quiz = quizController.quiz {
            let service = quizController.service
            service.session.progressDispatcher.dispatch(Progress(kind: .viewed, contextID: service.context, itemType: .quiz, itemID: quiz.id))
        }
    }
    
    fileprivate func takeabilityUpdated() {
        if let takeabilityController = self.takeabilityController {
            footerView.takeButton.isEnabled = true
            footerView.takeabilityUpdated(takeabilityController.takeability)

            // Alert if offline
            if case .notTakeable(.offline) = takeabilityController.takeability, !didShowOfflineAlert {
                didShowOfflineAlert = true
                let title = NSLocalizedString("Internet Connection Offline", comment: "")
                let message = NSLocalizedString("Answers will not be submitted while offline.", comment: "")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default, handler: nil)
                alert.addAction(dismiss)
                topMostViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Actions
    
    @objc func takeTheQuiz(_ button: UIButton?) {
        Analytics.shared.logEvent("quiz_taken")
        if let takeabilityController = self.takeabilityController {
            if takeabilityController.takeableNatively() {
                let controller = takeabilityController.submissionControllerForTakingQuiz(quizController.quiz!)
                let vc = QuizPresentingViewController(quizController: quizController, submissionController: controller)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
            } else if takeabilityController.takeableInWebView() {
                let vc = NonNativeQuizTakingViewController(session: takeabilityController.service.session, contextID: self.quizController.service.context, quiz: quizController.quiz!, baseURL: quizController.service.baseURL)
                vc.modalPresentationStyle = .fullScreen
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
            } else {
                var message = ""
                switch takeabilityController.takeability {
                case .viewResults(let url):
                    if let quiz = quizController.quiz, !quiz.requiresLockdownBrowserForResults {
                        let takeability = takeabilityController.takeability
                        footerView.takeabilityUpdated(.notTakeable(reason: .undecided))
                        takeabilityController.service.session.getAuthenticatedURL(forURL: url) { [weak self] result in
                            DispatchQueue.main.async {
                                self?.footerView.takeabilityUpdated(takeability)
                                switch result {
                                case .success(let url):
                                    UIApplication.shared.open(url)
                                case .failure(let error):
                                    let title = NSLocalizedString("Error", bundle: .core, comment: "")
                                    let ok = NSLocalizedString("OK", bundle: .core, comment: "")
                                    self?.showSimpleAlert(title, message: error.localizedDescription, actionText: ok)
                                }
                            }
                        }
                        return
                    } else {
                        message = NSLocalizedString("Lockdown Browser is required for viewing your results. Please open the quiz in Lockdown Browser to continue.", tableName: "Localizable", bundle: .core, value: "", comment: "Detail label for when a tool called Lockdown Browser is required to take the quiz")
                    }
                case .notTakeable(let reason):
                    switch reason {
                    case .attemptLimitReached:
                        message = NSLocalizedString("You have used all your attempts available on this quiz.", tableName: "Localizable", bundle: .core, value: "", comment: "Message when telling the user they can't take the quiz because they used up all their attempts")
                    case .ipFiltered:
                        message = NSLocalizedString("This quiz has an IP address filter set.", tableName: "Localizable", bundle: .core, value: "", comment: "Message when telling the user they can't take the quiz because the quiz has an IP address filter set")
                    case .locked:
                        message = NSLocalizedString("This quiz is locked.", tableName: "Localizable", bundle: .core, value: "", comment: "Message when telling the user they can't take the quiz because the quiz is locked")
                    case .undecided:
                        message = NSLocalizedString("This quiz is currently unavailable.", tableName: "Localizable", bundle: .core, value: "", comment: "Message when telling the user they can't take the quiz for some weird reason")
                    case .other:
                        message = NSLocalizedString("This quiz is locked.", tableName: "Localizable", bundle: .core, value: "", comment: "Message when telling the user they can't take the quiz because the quiz is locked") // not using the description for now - its HTML :(
                    case .offline:
                        message = NSLocalizedString("This quiz is not available offline.", tableName: "Localizable", bundle: .core, value: "", comment: "")
                    }
                default:
                    break
                }
                
                let alert = UIAlertController(title: NSLocalizedString("Not Takeable", tableName: "Localizable", bundle: .core, value: "", comment: "Title for alert showing when a quiz isn't takeable"), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: "OK Button Title"), style: .default, handler: { _ in }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Other stuffs
}

extension QuizIntroViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        for (index, page) in pages.enumerated() {
            if page === viewController && index > 0 {
                return pages[index-1]
            }
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        for (index, page) in pages.enumerated() {
            if page === viewController && index < pages.count-1 {
                return pages[index+1]
            }
        }
        return nil
    }
}

extension QuizIntroViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // update the current page number
            for (index, page) in pages.enumerated() {
                let vcs = pageViewController.viewControllers ?? []
                if page === vcs.first {
                    footerView.pageControl.currentPage = index
                    if index == pages.count - 1 { // if it's the last screen, remove the page indicator, bring in the big blue button
                        footerView.setTakeButtonOnscreen(true, animated: true)
                    } else {
                        footerView.setTakeButtonOnscreen(false, animated: true)
                    }
                }
            }
        }
    }
}

extension QuizIntroViewController {
    // This should only be routed to from assignment details that already checked takability & stored the quiz in CoreData
    public static func takeController(contextID: ContextID, quizID: String) -> UIViewController {
        guard let legacySession = Session.current else { return UIViewController() }
        let service = CanvasQuizService(session: legacySession, context: contextID, quizID: quizID)
        guard let model: Core.Quiz = AppEnvironment.shared.database.viewContext.first(where: #keyPath(Core.Quiz.id), equals: quizID),
            let mobileURL = model.mobileURL else {
            return QuizIntroViewController(quizController: QuizController(service: service, quiz: nil))
        }
        let quiz = Quiz(
            id: model.id,
            title: model.title,
            description: model.details ?? "",
            due: Quiz.Due(date: model.dueAt),
            timeLimit: model.timeLimit.flatMap({ Quiz.TimeLimit(minutes: Int($0)) }) ?? Quiz.TimeLimit.noTimeLimit,
            scoring: model.pointsPossible.flatMap({ Quiz.Scoring.pointsPossible(Int($0)) }) ?? Quiz.Scoring.ungraded,
            questionCount: model.questionCount,
            questionTypes: model.questionTypes.compactMap { Question.Kind(rawValue: $0.rawValue) },
            attemptLimit: Quiz.AttemptLimit(allowed: model.allowedAttempts),
            oneQuestionAtATime: model.oneQuestionAtATime,
            cantGoBack: model.cantGoBack,
            hideResults: Quiz.HideResults.fromJSON(model.hideResults?.rawValue)!,
            lockAt: model.lockAt,
            lockedForUser: model.lockedForUser,
            lockExplanation: model.lockExplanation,
            ipFilter: model.ipFilter,
            mobileURL: mobileURL,
            shuffleAnswers: model.shuffleAnswers,
            hasAccessCode: model.hasAccessCode,
            requiresLockdownBrowser: model.requireLockdownBrowser,
            requiresLockdownBrowserForResults: model.requireLockdownBrowserForResults
        )
        if model.takeInWebOnly {
            return NonNativeQuizTakingViewController(session: legacySession, contextID: contextID, quiz: quiz, baseURL: legacySession.baseURL)
        } else {
            var unfinishedSubmission: QuizSubmission?
            if let submission = model.submission, submission.canResume {
                unfinishedSubmission = QuizSubmission(
                    id: submission.id,
                    dateStarted: submission.startedAt,
                    dateFinished: submission.finishedAt,
                    endAt: submission.endAt,
                    attempt: submission.attempt,
                    attemptsLeft: submission.attemptsLeft,
                    validationToken: submission.validationToken ?? "",
                    workflowState: QuizSubmission.WorkflowState(rawValue: submission.workflowState.rawValue) ?? .Untaken,
                    extraTime: Int(submission.extraTime)
                )
            }
            let submissionController = SubmissionController(service: service, submission: unfinishedSubmission, quiz: quiz)
            return QuizPresentingViewController(quizController: QuizController(service: service, quiz: quiz), submissionController: submissionController)
        }
    }
}
