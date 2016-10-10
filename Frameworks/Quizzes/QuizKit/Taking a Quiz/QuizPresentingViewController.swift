//
//  QuizPresentingViewController.swift
//  Quizzes
//
//  Created by Ben Kraus on 3/20/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import Cartography
import TooLegit
import SoPretty
import SoLazy

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
    
    private let flaggedCountLabel = UILabel()
    private let flaggedButton = UIButton()
    
    private var timerVisible = false
    private let timerLabel = UILabel()
    private var timerToastViewVisible = false
    private let timerToastView = UIView()
    private let timerToastLabel = UILabel()
    private let timerToastViewConstraintGroup = ConstraintGroup()
    
    private let questionDrawerViewController = QuestionDrawerViewController(nibName: nil, bundle: nil)
    private let questionDrawerConstraintGroup = ConstraintGroup()
    private var questionDrawerActive = false
    private let contentOverlay = UIView()
    
    private var submissionViewController: SubmissionViewController!
    
    init(quizController: QuizController, submissionController: SubmissionController, questionsController: SubmissionQuestionsController? = nil) {
        self.quizController = quizController
        self.submissionController = submissionController
        self.questionsController = questionsController
        
        super.init(nibName: nil, bundle: nil)
        
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
            let alert = UIAlertController(title: NSLocalizedString("Quiz Due", comment: "Title for alert that shows when a quiz hits the due date"), message: NSLocalizedString("The quiz is due in 1 minute. Would you like to submit now and be on time or continue taking the quiz and possbily be late?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Description for alert that shows when the quiz hits the due date"), preferredStyle: .Alert)
            let beASlackerAction = UIAlertAction(title: NSLocalizedString("Continue Quiz", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Button for electing to be late on a quiz"), style: .Destructive, handler: { _ in })
            let notASlackerAction = UIAlertAction(title: NSLocalizedString("Submit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Button for electing to not be late on a quiz"), style: .Default, handler: { [weak self] _ in
                self?.goAheadAndSubmit()
            })
            alert.addAction(beASlackerAction)
            alert.addAction(notASlackerAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        submissionController.lockQuiz = { [weak self] in
            self?.goAheadAndSubmit(NSLocalizedString("Lock Date Reached\nSubmitting", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Label indicating that the quiz lock date was reached and the quiz is auto submitting"))
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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        submissionController.beginTakingQuiz()
    }
    
    private func prepareNavigationBar() {        
        if quizController.quiz != nil && !quizController.quiz!.cantGoBack {
            navigationItem.leftBarButtonItem = {
                let flagImage = UIImage(named: "flag_nav", inBundle: NSBundle(forClass: SubmissionViewController.classForCoder()), compatibleWithTraitCollection: nil)
                
                let flagView = UIView(frame: CGRect(x: 0, y: 0, width: flagImage?.size.width ?? 0, height: 34))

                flaggedButton.frame = flagView.bounds
                flaggedButton.setImage(flagImage?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                flaggedButton.tintColor = UIColor.whiteColor()
                flaggedButton.addTarget(self, action: #selector(QuizPresentingViewController.openDrawer(_:)), forControlEvents: .TouchUpInside)
                flaggedButton.accessibilityHint = NSLocalizedString("0 Questions Answered", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Accessiblity hint for question drawer button")
                flagView.addSubview(flaggedButton)
                
                self.flaggedCountLabel.frame = CGRect(x: 0.0, y: 0.0, width: flagView.frame.size.width - 8.0 /* arrow tip */, height: flagView.frame.size.height)
                self.flaggedCountLabel.textAlignment = .Center
                self.flaggedCountLabel.textColor = UIColor.whiteColor()
                self.flaggedCountLabel.font = UIFont.systemFontOfSize(12.0)
                flagView.addSubview(self.flaggedCountLabel)
                
                flaggedCountLabel.isAccessibilityElement = false
                
                return UIBarButtonItem(customView: flagView)
            }()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Exit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Exit button to leave the quiz"), style: .Plain, target: self, action: #selector(QuizPresentingViewController.exitQuiz(_:)))
    }
    
    private func prepareSubmissionView() {
        submissionViewController = SubmissionViewController(quiz: quizController.quiz, questions: (questionsController?.questions ?? []), whizzyBaseURL: submissionController.service.baseURL)
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
        submissionViewController!.didMoveToParentViewController(self)
        
        constrain(submissionViewController!.view) { submissionView in
            submissionView.edges == submissionView.superview!.edges; return
        }
        
        submissionViewController?.isLoading = questionsController?.isLoading ?? false
    }
    
    private func prepareQuestionDrawer() {
        questionDrawerViewController.questions = questionsController?.questions ?? []
        questionDrawerViewController.questionSelectionAction = { [weak self] questionIndex in
            if let me = self {
                me.closeDrawer()
                me.submissionViewController?.navigateToQuestionAtIndex(questionIndex)
            }
        }
        
        addChildViewController(questionDrawerViewController)
        view.addSubview(questionDrawerViewController.view)
        questionDrawerViewController.didMoveToParentViewController(self)
        
        constrain(questionDrawerViewController.view) { drawerView in
            drawerView.top      == drawerView.superview!.top
            drawerView.bottom   == drawerView.superview!.bottom
            drawerView.width    == 280
        }
        
        contentOverlay.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        view.insertSubview(contentOverlay, belowSubview: questionDrawerViewController.view)
        contentOverlay.hidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuizPresentingViewController.closeDrawer))
        contentOverlay.addGestureRecognizer(tapGesture)
        
        constrain(contentOverlay) { contentOverlay in
            contentOverlay.edges == contentOverlay.superview!.edges; return
        }
        
        setQuestionDrawerOnscreen(false, animated: false)
    }
    
    private func prepareTimer() {
        timerVisible = true
        
        timerLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        timerLabel.textAlignment = .Center
        timerLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        timerLabel.textColor = UIColor.whiteColor()
        timerLabel.text = ""
        timerLabel.userInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuizPresentingViewController.toggleTimer))
        timerLabel.addGestureRecognizer(tapGesture)
        
        navigationItem.titleView = timerLabel
        
        if quizController.quiz!.timed {
            view.addSubview(timerToastView)
            timerToastView.backgroundColor = Brand.current().tintColor
            constrain(timerToastView) { timerToastView in
                timerToastView.left     == timerToastView.superview!.left
                timerToastView.right    == timerToastView.superview!.right
                timerToastView.height   == 50
            }
            
            constrain(timerToastView, replace: timerToastViewConstraintGroup) { timerToastView in
                timerToastView.bottom   == timerToastView.superview!.top; return
            }
            
            timerToastView.addSubview(timerToastLabel)
            timerToastLabel.textColor = UIColor.whiteColor()
            timerToastLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            timerToastLabel.textAlignment = .Center
            constrain(timerToastLabel) { timerToastLabel in
                timerToastLabel.left    == timerToastLabel.superview!.left + 20
                timerToastLabel.right   == timerToastLabel.superview!.right - 20
                timerToastLabel.height  == 50
                timerToastLabel.centerY == timerToastLabel.superview!.centerY
            }
        }
    }
    
    private func reportError(err: NSError) {
        let title = NSLocalizedString("Quiz Error", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Title for quiz error")
        let dismiss = NSLocalizedString("Dismiss", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Dismiss button for error alert")
        
        var message = err.localizedDescription ?? NSLocalizedString("An unknown error has occurred.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "an unknown error's message")
        if let reason = err.localizedFailureReason {
            message += NSLocalizedString(" Failure reason: \(reason).", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Failure reason from the JSON payload from canvas")
        }
        if let reportID = err.userInfo[RequestErrorReportIDKey] as? Int {
            message += NSLocalizedString(" Error report ID: \(reportID)", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Error message component with the report id")
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: dismiss, style: .Default, handler: { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func updateTimer(currentTime: Int) {
        let hours: Int = currentTime / 3600
        let minutes: Int = (currentTime % 3600) / 60
        let seconds: Int = (currentTime % 3600) % 60
        
        if self.timerVisible {
            var displayString: String = ""
            // yeah I could probably figure some other way of displaying this better...
            if hours > 0 {
                displayString = String(format: "%d:%02d:%02d", hours, minutes, seconds) // show something like "1:29:31"
            } else if minutes > 0 {
                displayString = String(format: "%d:%02d", minutes, seconds) // show something like "4:34"
            } else {
                displayString = String(format: "%02d:%02d", minutes, seconds) // show something like "00:35"
            }
            
            self.timerLabel.text = displayString
        }
        
        if currentTime == 300 /* 5 minutes */ && quizController.quiz!.timed {
            let text = NSLocalizedString("5 minutes remaining", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Notification to alert the user that there is only 5 minutes left in the timed quiz")
            showTimerToastWithText(text)
        }
        
        if currentTime == 30 && quizController.quiz!.timed {
            let text = NSLocalizedString("30 seconds remaining", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Notification to alert the user that there is only 30 seconds left in the time quiz")
            showTimerToastWithText(text)
        }
    }
    
    // MARK: - Actions
    
    func openDrawer(button: UIBarButtonItem?) {
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
    
    func exitQuiz(button: UIBarButtonItem?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func setQuestionDrawerOnscreen(onscreen: Bool, animated: Bool) {
        navigationItem.rightBarButtonItem?.enabled = !onscreen

        if onscreen {
            constrain(questionDrawerViewController.view, replace: questionDrawerConstraintGroup) { drawerView in
                drawerView.leading == drawerView.superview!.leading; return
            }
            contentOverlay.alpha = 0.0
            contentOverlay.hidden = false
            questionDrawerViewController.view.accessibilityViewIsModal = true
            flaggedButton.accessibilityLabel = NSLocalizedString("Hide Question List", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Hides the question list")
        } else {
            constrain(questionDrawerViewController.view, replace: questionDrawerConstraintGroup) { drawerView in
                drawerView.trailing == drawerView.superview!.leading; return
            }
            questionDrawerViewController.view.accessibilityViewIsModal = false
            flaggedButton.accessibilityLabel = NSLocalizedString("Show Question List", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Hides the question list")
        }
        
        let setOverlayAlpa: ()->() = {
            if onscreen {
                self.contentOverlay.alpha = 1.0
            } else {
                self.contentOverlay.alpha = 0.0
            }
        }
        if animated {
            UIView.animateWithDuration(0.2, animations: {
                setOverlayAlpa()
                self.view.layoutIfNeeded()
            }, completion: { _ in
                if !onscreen {
                    self.contentOverlay.hidden = true
                }
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
            })
        } else {
            setOverlayAlpa()
            view.layoutIfNeeded()
            if !onscreen {
                self.contentOverlay.hidden = true
            }
        }
    }
    
    func toggleTimer() {
        timerVisible = !timerVisible
        
        if timerVisible {
            updateTimer(quizSubmissionTimerController!.timerTime)
        } else {
            timerLabel.text = NSLocalizedString("Show Timer", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Text for a button that toggles to show a timer for a timed quiz")
        }
    }
    
    private func showTimerToastWithText(text: String) {
        if timerToastViewVisible {
            return
        }
        
        timerToastViewVisible = true
        timerToastLabel.text = text
        
        constrain(timerToastView, replace: self.timerToastViewConstraintGroup) { timerToastView in
            timerToastView.top == timerToastView.superview!.top+self.topLayoutGuide.length; return
        }
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))) // 5 seconds
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            constrain(self.timerToastView, replace: self.timerToastViewConstraintGroup) { timerToastView in
                timerToastView.bottom == timerToastView.superview!.top; return
            }
            UIView.animateWithDuration(0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.timerToastViewVisible = false
            })
        }
    }
}

// MARK - Submission

extension QuizPresentingViewController {
    func confirmSubmission(onConfirm onConfirm: ()->()) {
        if questionsController == nil {
            return
        }
        
        let unansweredCount = questionsController!.questions.reduce(0) { unansweredCount, question in
            switch question.answer {
            case .Unanswered:
                return unansweredCount + 1
            case .Matches(let matches) where matches.keys.count < question.question.answers.count:
                return unansweredCount + 1
            default:
                return unansweredCount
            }
        }
        
        var title: String? = nil
        let message = NSLocalizedString("Are you sure you want to submit your answers?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Confirmation before submitting a quiz")
        if unansweredCount > 0 {
            title = String(format: NSLocalizedString("%d questions not answered", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Confirmations alerting user of unanswered questions"), unansweredCount)
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // yes, I'm ready
        let forTheGlory = NSLocalizedString("Submit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "confirm submitting quiz")
        alert.addAction(UIAlertAction(title: forTheGlory, style: .Default, handler:{ _ in
            onConfirm(); return
        }))
        
        // false, I'm having doubts
        let noMaybeNot = NSLocalizedString("Cancel", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "cancel button for submitting a quiz")
        alert.addAction(UIAlertAction(title: noMaybeNot, style: .Cancel, handler: { _ in
            print("cancelled submission"); return
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func goAheadAndSubmit(customLoadingText: String? = nil) {
        let submit: ()->Void = {
            let confirmationViewController = SubmissionConfirmationViewController(resultsURL: self.quizController.urlForViewingResultsForAttempt(self.submissionController.submission!.attempt))
            confirmationViewController.customLoadingText = customLoadingText
            confirmationViewController.showState(.Loading)
            self.presentViewController(UINavigationController(rootViewController: confirmationViewController), animated: true, completion: nil)

            self.submissionController.submit { result in
                if let _ = result.error {
                    confirmationViewController.showState(.Failed)
                } else {
                    confirmationViewController.showState(.Successful)
                }
            }
        }

        submissionViewController.answerUnsubmittedQuestions() {
            submit()
        }
    }
}

extension QuizPresentingViewController {
    func handleQuestionsUpdateResult(result: SubmissionQuestionsUpdateResult) {
        if let error = result.error {
            reportError(error)
            return
        }
            
        else if let updates = result.value {
            for update in updates {
                switch update {
                case .Added(_):
                    flaggedCountLabel.text = "\(questionsController!.flaggedCount)"
                case .AnswerChanged(_):
                    break
                case .FlagChanged(_):
                    flaggedCountLabel.text = "\(questionsController!.flaggedCount)"
                }
            }
            
            flaggedButton.accessibilityHint = NSLocalizedString("\(questionsController!.flaggedCount) Questions Answered", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Accessiblity hint for question drawer button")
        }
    }
}
