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
