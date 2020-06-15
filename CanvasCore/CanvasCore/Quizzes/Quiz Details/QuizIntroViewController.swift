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
    
    fileprivate lazy var details = QuizDetailsViewController(
        quiz: quizController.quiz,
        baseURL: quizController.service.baseURL
    )
    
    fileprivate let footerView: QuizIntroFooterView = QuizIntroFooterView()

    fileprivate var didShowOfflineAlert = false
    
    public convenience init(session: Session, courseID: String, quizID: String) {
        let context = Context(.course, id: courseID)
        let service = CanvasQuizService(session: session, context: context, quizID: quizID)
        let controller = QuizController(service: service, quiz: nil)

        self.init(quizController: controller)
    }
    
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

        title = NSLocalizedString("Quiz Details", bundle: .core, comment: "")
        embed(details, in: view)
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
    
    fileprivate func updateTakeButtonAndPages() {
        footerView.setTakeButtonOnscreen(true, animated: true)
    }
    
    fileprivate func quizUpdated() {
        details.quizController = quizController
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
            if takeabilityController.takeableInWebView() {
                let vc = NonNativeQuizTakingViewController(session: takeabilityController.service.session, contextID: quizController.service.context, quizID: quizController.quiz!.id, url: quizController.quiz!.mobileURL)
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
}

extension QuizIntroViewController {
    // This should only be routed to from assignment details that already checked takability & stored the quiz in CoreData
    public static func takeController(contextID: Context, quizID: String) -> UIViewController {
        guard let legacySession = Session.current else { return UIViewController() }
        let service = CanvasQuizService(session: legacySession, context: contextID, quizID: quizID)
        guard let model: Core.Quiz = AppEnvironment.shared.database.viewContext.first(where: #keyPath(Core.Quiz.id), equals: quizID),
            let mobileURL = model.mobileURL else {
            return QuizIntroViewController(quizController: QuizController(service: service, quiz: nil))
        }
        return NonNativeQuizTakingViewController(session: legacySession, contextID: contextID, quizID: model.id, url: mobileURL)
    }
}
