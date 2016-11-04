//
//  SubmissionPageViewController.swift
//  SwiftGrader
//
//  Created by Derrick Hathaway on 10/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Peeps
import SoPersistent
import AssignmentKit
import TooLegit

class SubmissionPageViewController: UIPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        dataSource = self
        delegate = self
    }
    
    func createViewController(iterator: GradingIterator) -> SubmissionViewController {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("SubmissionViewController") as! SubmissionViewController
        let submissionProducer = submissionsObserver.producer(iterator.enrollment.user!.id)
        vc.observeSubmission(submissionProducer, iterator: iterator, assignment: assignment, inSession: session)
        
        return vc
    }
    
    func loadSubmissions(enrollments collection: FetchedCollection<UserEnrollment>, submissionsObserver: ManagedObjectsObserver<Submission, String>, assignment: Assignment, inSession session: Session) {
        self.session = session
        self.assignment = assignment
        self.submissionsObserver = submissionsObserver
        let iterator = GradingIterator(collection: collection)
        
        let current = createViewController(iterator)
        currentPage.value = current
        nextPage = createViewController(iterator.next)
        previousPage = createViewController(iterator.previous)
        setViewControllers([current], direction: .Forward, animated: false, completion: nil)
    }
    
    var session: Session!
    var assignment: Assignment!
    
    var nextPage: SubmissionViewController?
    var previousPage: SubmissionViewController?
    let currentPage = MutableProperty<SubmissionViewController?>(nil)
    
    var navigationDirection: UIPageViewControllerNavigationDirection = .Forward
    var submissionsObserver: ManagedObjectsObserver<Submission, String>!
}


extension SubmissionPageViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        return nextPage
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        return previousPage
    }
}


extension SubmissionPageViewController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        if pendingViewControllers.first == nextPage {
            navigationDirection = .Forward
            print("Forward")
        } else {
            navigationDirection = .Reverse
            print("Reverse")
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            switch navigationDirection {
            case .Forward:
                previousPage = currentPage.value
                currentPage.value = nextPage
                nextPage = (nextPage?.iterator?.next).map(self.createViewController)
            case .Reverse:
                nextPage = currentPage.value
                currentPage.value = previousPage
                previousPage = (previousPage?.iterator?.previous).map(self.createViewController)
            }
        }
    }
}
