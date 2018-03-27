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
import Cartography




class QuizPresentingViewController: UIViewController {
    
    let quizController: QuizController
    let submissionController: SubmissionController
    var questionsController: SubmissionQuestionsController? {
        didSet {
            if let controller = questionsController {
                controller.questionUpdates = { [weak self] updateResult in
                    self?.questionDrawerViewController.questions = self?.questionsController?.questions ?? []
                    self?.submissionViewController?.questions = self?.questionsController?.questions ?? []
                    
                    self?.handleQuestionsUpdateResult(updateResult)
                    self?.submissionViewController?.handleQuestionsUpdateResult(updateResult)
                    self?.questionDrawerViewController.handleQuestionsUpdateResult(updateResult)
                }
                
                questionDrawerViewController.isLoading = questionsController?.isLoading ?? false
                controller.loadingChanged = { [weak self] isLoading in
                    self?.submissionViewController?.isLoading = isLoading
                    self?.questionDrawerViewController.isLoading = isLoading
                }
            }
        }
    }
    var quizSubmissionTimerController: QuizSubmissionTimerController?
    
    fileprivate let flaggedCountLabel = UILabel()
    fileprivate let flaggedButton = UIButton()
    fileprivate static let flaggedCountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    fileprivate var timerVisible = false
    fileprivate let timerLabel = UILabel()
    fileprivate var timerToastViewVisible = false
    fileprivate let timerToastView = UIView()
    fileprivate let timerToastLabel = UILabel()
    fileprivate let timerToastViewConstraintGroup = ConstraintGroup()
    
    fileprivate let questionDrawerViewController = QuestionDrawerViewController(nibName: nil, bundle: nil)
    fileprivate let questionDrawerConstraintGroup = ConstraintGroup()
    fileprivate var questionDrawerActive = false
    fileprivate let contentOverlay = UIView()
    
    fileprivate var submissionViewController: SubmissionViewController!

    fileprivate var timerFormatter = DateComponentsFormatter()
    
    init(quizController: QuizController, submissionController: SubmissionController, questionsController: SubmissionQuestionsController? = nil) {
        self.quizController = quizController
        self.submissionController = submissionController
        self.questionsController = questionsController
        
        super.init(nibName: nil, bundle: nil)

        timerFormatter.unitsStyle = .positional
        timerFormatter.allowedUnits = [.hour, .minute, .second]
        
        submissionController.submissionDidChange = { [weak self] submissionResult in
            if let error = submissionResult.error {
                self?.reportError(error)
            } else {
                self?.questionsController = submissionController.controllerForSubmissionQuestions
                self?.submissionViewController?.submissionInteractor = self?.questionsController
                
                let submission = self?.submissionController.submission
                
                let timedQuizService = quizController.service.serviceForTimedQuizSubmission(submission!)
                self?.quizSubmissionTimerController = QuizSubmissionTimerController(quiz: quizController.quiz!, timedQuizSubmissionService: timedQuizService)
                self?.quizSubmissionTimerController?.timerTick = { [weak self] secondsLeft in
                    if let me = self {
                        me.updateTimer(secondsLeft)
                    }
                }
                self?.quizSubmissionTimerController?.timeExpired = { [weak self] in
                    if let me = self {
                        me.goAheadAndSubmit()
                    }
                }
                self?.quizSubmissionTimerController?.startSubmission(submission!)
            }
        }
        submissionController.almostDue = {
            let alert = UIAlertController(title: NSLocalizedString("Quiz Due", comment: "Title for alert that shows when a quiz hits the due date"), message: NSLocalizedString("The quiz is due in 1 minute. Would you like to submit now and be on time or continue taking the quiz and possibly be late?", tableName: "Localizable", bundle: .core, value: "", comment: "Description for alert that shows when the quiz hits the due date"), preferredStyle: .alert)
            let beASlackerAction = UIAlertAction(title: NSLocalizedString("Continue Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "Button for electing to be late on a quiz"), style: .destructive, handler: { _ in })
            let notASlackerAction = UIAlertAction(title: NSLocalizedString("Submit", tableName: "Localizable", bundle: .core, value: "", comment: "Submit button title"), style: .default, handler: { [weak self] _ in
                self?.goAheadAndSubmit()
            })
            alert.addAction(beASlackerAction)
            alert.addAction(notASlackerAction)
            self.present(alert, animated: true, completion: nil)
        }
        submissionController.lockQuiz = { [weak self] in
            self?.goAheadAndSubmit(NSLocalizedString("Lock Date Reached\nSubmitting", tableName: "Localizable", bundle: .core, value: "", comment: "Label indicating that the quiz lock date was reached and the quiz is auto submitting"))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationBar()
        prepareSubmissionView()
        prepareQuestionDrawer()
        prepareTimer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        submissionController.beginTakingQuiz()
    }
    
    fileprivate func prepareNavigationBar() {        
        if quizController.quiz != nil && !quizController.quiz!.cantGoBack {
            navigationItem.leftBarButtonItem = {
                let flagImage = UIImage(named: "flag_nav", in: Bundle(for: SubmissionViewController.classForCoder()), compatibleWith: nil)
                
                let flagView = UIView(frame: CGRect(x: 0, y: 0, width: flagImage?.size.width ?? 0, height: 34))

                flaggedButton.frame = flagView.bounds
                flaggedButton.setImage(flagImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                flaggedButton.addTarget(self, action: #selector(QuizPresentingViewController.openDrawer(_:)), for: .touchUpInside)
                flaggedButton.accessibilityHint = NSLocalizedString("0 Questions Answered", tableName: "Localizable", bundle: .core, value: "", comment: "Accessiblity hint for question drawer button")
                flagView.addSubview(flaggedButton)
                
                self.flaggedCountLabel.frame = CGRect(x: 0.0, y: 0.0, width: flagView.frame.size.width - 8.0 /* arrow tip */, height: flagView.frame.size.height)
                self.flaggedCountLabel.textAlignment = .center
                self.flaggedCountLabel.textColor = UIColor.white
                self.flaggedCountLabel.font = UIFont.systemFont(ofSize: 12.0)
                flagView.addSubview(self.flaggedCountLabel)
                
                flaggedCountLabel.isAccessibilityElement = false
                
                return UIBarButtonItem(customView: flagView)
            }()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Exit", tableName: "Localizable", bundle: .core, value: "", comment: "Exit button to leave the quiz"), style: .plain, target: self, action: #selector(QuizPresentingViewController.exitQuiz(_:)))
    }
    
    fileprivate func prepareSubmissionView() {
        submissionViewController = SubmissionViewController(quiz: quizController.quiz, questions: (questionsController?.questions ?? []), whizzyBaseURL: submissionController.service.baseURL, quizService: quizController.service)
        submissionViewController?.submissionInteractor = questionsController
        submissionViewController?.submitAction = { [weak self] in
            if let me = self {
                me.confirmSubmission {
                    me.goAheadAndSubmit()
                }
            }
        }
        
        addChildViewController(submissionViewController!)
        view.addSubview(submissionViewController!.view)
        submissionViewController!.didMove(toParentViewController: self)
        
        constrain(submissionViewController!.view) { submissionView in
            submissionView.edges == submissionView.superview!.edges; return
        }
        
        submissionViewController?.isLoading = questionsController?.isLoading ?? false
    }
    
    fileprivate func prepareQuestionDrawer() {
        questionDrawerViewController.questions = questionsController?.questions ?? []
        questionDrawerViewController.questionSelectionAction = { [weak self] questionIndex in
            if let me = self {
                me.closeDrawer()
                me.submissionViewController?.navigateToQuestionAtIndex(questionIndex)
            }
        }
        
        addChildViewController(questionDrawerViewController)
        view.addSubview(questionDrawerViewController.view)
        questionDrawerViewController.didMove(toParentViewController: self)
        
        constrain(questionDrawerViewController.view) { drawerView in
            drawerView.top      == drawerView.superview!.top
            drawerView.bottom   == drawerView.superview!.bottom
            drawerView.width    == 280
        }
        
        contentOverlay.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        view.insertSubview(contentOverlay, belowSubview: questionDrawerViewController.view)
        contentOverlay.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuizPresentingViewController.closeDrawer))
        contentOverlay.addGestureRecognizer(tapGesture)
        
        constrain(contentOverlay) { contentOverlay in
            contentOverlay.edges == contentOverlay.superview!.edges; return
        }
        
        setQuestionDrawerOnscreen(false, animated: false)
    }
    
    fileprivate func prepareTimer() {
        timerVisible = true
        
        timerLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        timerLabel.text = ""
        timerLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuizPresentingViewController.toggleTimer))
        timerLabel.addGestureRecognizer(tapGesture)
        
        navigationItem.titleView = timerLabel
        
        if quizController.quiz!.timed {
            view.addSubview(timerToastView)
            timerToastView.backgroundColor = Brand.current.tintColor
            constrain(timerToastView) { timerToastView in
                timerToastView.left     == timerToastView.superview!.left
                timerToastView.right    == timerToastView.superview!.right
                timerToastView.height   == 50
            }
            
            constrain(timerToastView, replace: timerToastViewConstraintGroup) { timerToastView in
                timerToastView.bottom   == timerToastView.superview!.top; return
            }
            
            timerToastView.addSubview(timerToastLabel)
            timerToastLabel.textColor = UIColor.white
            timerToastLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            timerToastLabel.textAlignment = .center
            constrain(timerToastLabel) { timerToastLabel in
                timerToastLabel.left    == timerToastLabel.superview!.left + 20
                timerToastLabel.right   == timerToastLabel.superview!.right - 20
                timerToastLabel.height  == 50
                timerToastLabel.centerY == timerToastLabel.superview!.centerY
            }
        }
    }
    
    fileprivate func reportError(_ err: NSError) {
        let title = NSLocalizedString("Quiz Error", tableName: "Localizable", bundle: .core, value: "", comment: "Title for quiz error")
        let dismiss = NSLocalizedString("Dismiss", tableName: "Localizable", bundle: .core, value: "", comment: "Dismiss button for error alert")
        
        var message = (err.userInfo[NSLocalizedDescriptionKey] as? String) ?? NSLocalizedString("An unknown error has occurred.", tableName: "Localizable", bundle: .core, value: "", comment: "an unknown error's message")
        if let reason = err.localizedFailureReason {
            message += NSLocalizedString(" Failure reason: \(reason).", tableName: "Localizable", bundle: .core, value: "", comment: "Failure reason from the JSON payload from canvas")
        }
        if let reportID = err.userInfo[RequestErrorReportIDKey] as? Int {
            message += NSLocalizedString(" Error report ID: \(reportID)", tableName: "Localizable", bundle: .core, value: "", comment: "Error message component with the report id")
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismiss, style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateTimer(_ currentTime: Int) {
        if self.timerVisible {
            let timeInterval = TimeInterval(currentTime)
            let displayString = timerFormatter.string(from: timeInterval)
            self.timerLabel.text = displayString
        }
        
        if currentTime == 300 /* 5 minutes */ && quizController.quiz!.timed {
            let text = NSLocalizedString("5 minutes remaining", tableName: "Localizable", bundle: .core, value: "", comment: "Notification to alert the user that there is only 5 minutes left in the timed quiz")
            showTimerToastWithText(text)
        }
        
        if currentTime == 30 && quizController.quiz!.timed {
            let text = NSLocalizedString("30 seconds remaining", tableName: "Localizable", bundle: .core, value: "", comment: "Notification to alert the user that there is only 30 seconds left in the time quiz")
            showTimerToastWithText(text)
        }
    }
    
    // MARK: - Actions
    
    func openDrawer(_ button: UIBarButtonItem?) {
        questionDrawerActive = !questionDrawerActive
        if questionDrawerActive {
            setQuestionDrawerOnscreen(true, animated: true)
        } else {
            setQuestionDrawerOnscreen(false, animated: true)
        }
    }
    
    func closeDrawer() {
        questionDrawerActive = false
        setQuestionDrawerOnscreen(false, animated: true)
    }
    
    func exitQuiz(_ button: UIBarButtonItem?) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setQuestionDrawerOnscreen(_ onscreen: Bool, animated: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = !onscreen

        if onscreen {
            constrain(questionDrawerViewController.view, replace: questionDrawerConstraintGroup) { drawerView in
                drawerView.leading == drawerView.superview!.leading; return
            }
            contentOverlay.alpha = 0.0
            contentOverlay.isHidden = false
            questionDrawerViewController.view.accessibilityViewIsModal = true
            flaggedButton.accessibilityLabel = NSLocalizedString("Hide Question List", tableName: "Localizable", bundle: .core, value: "", comment: "Hides the question list")
        } else {
            constrain(questionDrawerViewController.view, replace: questionDrawerConstraintGroup) { drawerView in
                drawerView.trailing == drawerView.superview!.leading; return
            }
            questionDrawerViewController.view.accessibilityViewIsModal = false
            flaggedButton.accessibilityLabel = NSLocalizedString("Show Question List", tableName: "Localizable", bundle: .core, value: "", comment: "Hides the question list")
        }
        
        let setOverlayAlpa: ()->() = {
            if onscreen {
                self.contentOverlay.alpha = 1.0
            } else {
                self.contentOverlay.alpha = 0.0
            }
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                setOverlayAlpa()
                self.view.layoutIfNeeded()
            }, completion: { _ in
                if !onscreen {
                    self.contentOverlay.isHidden = true
                }
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
            })
        } else {
            setOverlayAlpa()
            view.layoutIfNeeded()
            if !onscreen {
                self.contentOverlay.isHidden = true
            }
        }
    }
    
    func toggleTimer() {
        timerVisible = !timerVisible
        
        if timerVisible {
            updateTimer(quizSubmissionTimerController!.timerTime)
        } else {
            timerLabel.text = NSLocalizedString("Show Timer", tableName: "Localizable", bundle: .core, value: "", comment: "Text for a button that toggles to show a timer for a timed quiz")
        }
    }
    
    fileprivate func showTimerToastWithText(_ text: String) {
        if timerToastViewVisible {
            return
        }
        
        timerToastViewVisible = true
        timerToastLabel.text = text
        
        constrain(timerToastView, replace: self.timerToastViewConstraintGroup) { timerToastView in
            timerToastView.top == timerToastView.superview!.top+self.topLayoutGuide.length; return
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
        
        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) // 5 seconds
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            constrain(self.timerToastView, replace: self.timerToastViewConstraintGroup) { timerToastView in
                timerToastView.bottom == timerToastView.superview!.top; return
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.timerToastViewVisible = false
            })
        }
    }
}

// MARK - QuizSubmission

extension QuizPresentingViewController {
    func confirmSubmission(onConfirm: @escaping ()->()) {
        if questionsController == nil {
            return
        }
        
        let unansweredCount = questionsController!.questions.reduce(0) { unansweredCount, question in
            switch question.answer {
            case .unanswered:
                return unansweredCount + 1
            case .Matches(let matches) where matches.keys.count < question.question.answers.count:
                return unansweredCount + 1
            default:
                return unansweredCount
            }
        }
        
        var title: String? = nil
        let message = NSLocalizedString("Are you sure you want to submit your answers?", tableName: "Localizable", bundle: .core, value: "", comment: "Confirmation before submitting a quiz")
        if unansweredCount > 0 {
            title = String(format: NSLocalizedString("%d questions not answered", tableName: "Localizable", bundle: .core, value: "", comment: "Confirmations alerting user of unanswered questions"), unansweredCount)
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // yes, I'm ready
        let forTheGlory = NSLocalizedString("Submit", tableName: "Localizable", bundle: .core, value: "", comment: "Submit button title")
        alert.addAction(UIAlertAction(title: forTheGlory, style: .default, handler:{ _ in
            onConfirm(); return
        }))
        
        // false, I'm having doubts
        let noMaybeNot = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .core, value: "", comment: "Cancel button title")
        alert.addAction(UIAlertAction(title: noMaybeNot, style: .cancel, handler: { _ in
            print("cancelled submission"); return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func goAheadAndSubmit(_ customLoadingText: String? = nil) {
        submissionViewController.answerUnsubmittedQuestions() { [weak self] in
            guard let me = self, let submission = me.submissionController.submission else { return }

            let confirmationViewController = SubmissionConfirmationViewController(resultsURL: me.quizController.urlForViewingResultsForAttempt(submission.attempt), requiresLockdownBrowserForViewingResults: me.quizController.quiz?.requiresLockdownBrowserForResults ?? false)
            confirmationViewController.customLoadingText = customLoadingText
            confirmationViewController.showState(.loading)
            me.present(UINavigationController(rootViewController: confirmationViewController), animated: true, completion: nil)

            me.submissionController.submit { result in
                if let _ = result.error {
                    confirmationViewController.showState(.failed)
                } else {
                    confirmationViewController.showState(.successful)
                }
            }
        }
    }
}

extension QuizPresentingViewController {
    func handleQuestionsUpdateResult(_ result: SubmissionQuestionsUpdateResult) {
        if let error = result.error {
            reportError(error)
            return
        }
            
        else if let updates = result.value {
            guard let questionsController = questionsController else { return }

            let flaggedCountString = QuizPresentingViewController.flaggedCountFormatter.string(from: NSNumber(value: questionsController.flaggedCount)) ?? ""

            for update in updates {
                switch update {
                case .added(_), .flagChanged(_):
                    flaggedCountLabel.text = flaggedCountString
                case .answerChanged(_):
                    break
                }
            }
            
            flaggedButton.accessibilityHint = String(format: NSLocalizedString("%@ Questions Answered", tableName: "Localizable", bundle: .core, value: "", comment: "Accessiblity hint for question drawer button"), flaggedCountString)
        }
    }
}
