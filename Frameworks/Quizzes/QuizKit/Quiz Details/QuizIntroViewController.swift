//
//  QuizIntroViewController.swift
//  Quizzes
//
//  Created by Ben Kraus on 3/3/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import Cartography
import SoPretty
import TooLegit
import SoLazy
import SoProgressive

public class QuizIntroViewController: UIViewController {
    
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
                self?.takeabilityUpdated(); return
            }
        }
    }
    
    private var pages: [UIViewController] = []
    private let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
    private let footerView: QuizIntroFooterView = QuizIntroFooterView()
    
    init(quizController: QuizController) {
        self.quizController = quizController
        super.init(nibName: nil, bundle: nil)
        
        self.quizController.quizUpdated = { [weak self] result in
            if let error = result.error {
                let title = ""
                let message = ""
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "", style: .Cancel, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
            
            if let quiz = result.value?.content {
                self?.takeabilityController = QuizTakeabilityController(quiz: quiz, service: quizController.service)
                self?.takeabilityController?.refreshTakeability()
            }
            
            self?.quizUpdated()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        preparePageViewController()
        prepareFooterView()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.quizController.refreshQuiz()
    }
    
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ _ in
            // who cares?
        }, completion: { _ in
            let currentPage = self.footerView.pageControl.currentPage
            guard currentPage < self.pages.count else { return }
            
            let vc = self.pages[self.footerView.pageControl.currentPage]
            self.pageViewController.setViewControllers([vc], direction: .Forward, animated: false, completion: nil)
        })
    }
    
    private func preparePageViewController() {
        automaticallyAdjustsScrollViewInsets = false
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor.whiteColor()
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        constrain(view, pageViewController.view) { view, pageView in
            pageView.size == view.size
            pageView.center == view.center
        }

        pages = [buildQuizDetailsPage()]
        pageViewController.setViewControllers(pages, direction: .Forward, animated: false, completion: nil)

    }
    
    private func prepareFooterView() {
        view.addSubview(footerView)
        constrain(view, footerView) { view, footerView in
            footerView.left == view.left
            footerView.right == view.right
            footerView.height == 60
        }
        
        let bottomConstraint = NSLayoutConstraint(item: footerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint)
        
        
        footerView.takeButton.addTarget(self, action: #selector(QuizIntroViewController.takeTheQuiz(_:)), forControlEvents: .TouchUpInside)
    }
    
    private func buildQuizDetailsPage() -> QuizDetailsViewController {
        let vc = QuizDetailsViewController(quiz: self.quizController.quiz, baseURL: self.quizController.service.baseURL)
        return vc
    }
    
    private func buildAnswersFinalPage() -> AnswersFinalViewController {
        return AnswersFinalViewController(nibName: "AnswersFinalViewController", bundle: NSBundle(forClass: QuizIntroViewController.self))
    }
    
    private func buildTimedQuizPage() -> TimedQuizViewController {
        let vc = TimedQuizViewController(nibName: "TimedQuizViewController", bundle: NSBundle(forClass: QuizIntroViewController.self))
        let _ = vc.view // force the hooking up of the outlet
        return vc
    }
    
    private func updateTakeButtonAndPages() {
        if pages.count == 1 {
            footerView.pageControl.hidden = true
            footerView.setTakeButtonOnscreen(true, animated: true)
        } else {
            footerView.pageControl.hidden = false
            footerView.setTakeButtonOnscreen(false, animated: true)
        }
        
        footerView.pageControl.currentPage = 0
        footerView.pageControl.numberOfPages = pages.count
    }
    
    private func quizUpdated() {
        // This is a very pared down implementation making a lot of assumptions.
        // Assumptions being, that this updated block would only be called once after fetching the quiz,
        // and not continously in a reactive stream style.
        
        // this stuff is just for precaution, incase you didn't see the above note and it started doing some funky stuff
        if pages.count > 1 {
            pages.removeRange(1...(pages.count-1))
        }
        pageViewController.setViewControllers(pages, direction: .Forward, animated: false, completion: nil)
        
        let detailsPage = pages[0] as! QuizDetailsViewController
        detailsPage.quiz = quizController.quiz
        
        if quizController.quiz != nil {
            if quizController.quiz!.oneQuestionAtATime && quizController.quiz!.cantGoBack {
                pages.append(buildAnswersFinalPage())
            }
            switch quizController.quiz!.timeLimit {
            case .Minutes(let minutes):
                let page = buildTimedQuizPage()
                page.minuteLimit = minutes
                pages.append(page)
            default: break
            }
        }
        
        updateTakeButtonAndPages()
        
        if let quiz = quizController.quiz {
            let service = quizController.service
            service.session.progressDispatcher.dispatch(Progress(kind: .Viewed, contextID: service.context, itemType: .Quiz, itemID: quiz.id))
        }
    }
    
    private func takeabilityUpdated() {
        if let takeabilityController = self.takeabilityController {
            footerView.takeButton.enabled = true
            footerView.takeabilityUpdated(takeabilityController.takeability)
        }
    }
    
    // MARK: Actions
    
    func takeTheQuiz(button: UIButton?) {
        if let takeabilityController = self.takeabilityController {
            if takeabilityController.takeableNatively() {
                let controller = takeabilityController.submissionControllerForTakingQuiz(quizController.quiz!)
                let vc = QuizPresentingViewController(quizController: quizController, submissionController: controller)
                presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            } else if takeabilityController.takeableInWebView() {
                let vc = NonNativeQuizTakingViewController(session: takeabilityController.service.session, contextID: self.quizController.service.context, quiz: quizController.quiz!, baseURL: quizController.service.baseURL)
                presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            } else {
                var message = ""
                switch takeabilityController.takeability {
                case .NotTakeable(let reason):
                    switch reason {
                    case .AttemptLimitReached:
                        message = NSLocalizedString("You have used all your attempts available on this quiz.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Message when telling the user they can't take the quiz because they used up all their attempts")
                    case .IPFiltered:
                        message = NSLocalizedString("This quiz has an IP address filter set.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Message when telling the user they can't take the quiz because the quiz has an IP address filter set")
                    case .Locked:
                        message = NSLocalizedString("This quiz is locked.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Message when telling the user they can't take the quiz because the quiz is locked")
                    case .Undecided:
                        message = NSLocalizedString("This quiz is currently unavailable.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Message when telling the user they can't take the quiz for some weird reason")
                    case .Other:
                        message = NSLocalizedString("This quiz is locked.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Message when telling the user they can't take the quiz because the quiz is locked") // not using the description for now - its HTML :(
                    }
                default:
                    break
                }
                
                let alert = UIAlertController(title: NSLocalizedString("Not Takeable", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Title for alert showing when a quiz isn't takeable"), message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "OK"), style: .Default, handler: { _ in }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Other stuffs
}

extension QuizIntroViewController: UIPageViewControllerDataSource {
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        for (index, page) in pages.enumerate() {
            if page === viewController && index > 0 {
                return pages[index-1]
            }
        }
        return nil
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        for (index, page) in pages.enumerate() {
            if page === viewController && index < pages.count-1 {
                return pages[index+1]
            }
        }
        return nil
    }
}

extension QuizIntroViewController: UIPageViewControllerDelegate {
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // update the current page number
            for (index, page) in pages.enumerate() {
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
