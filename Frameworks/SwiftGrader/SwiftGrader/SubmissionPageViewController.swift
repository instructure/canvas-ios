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
import ReactiveSwift
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
    
    func createViewController(_ iterator: GradingIterator) -> SubmissionViewController {
        let vc = storyboard!.instantiateViewController(withIdentifier: "SubmissionViewController") as! SubmissionViewController
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
        setViewControllers([current], direction: .forward, animated: false, completion: nil)
    }
    
    var session: Session!
    var assignment: Assignment!
    
    var nextPage: SubmissionViewController?
    var previousPage: SubmissionViewController?
    let currentPage = MutableProperty<SubmissionViewController?>(nil)
    
    var navigationDirection: UIPageViewControllerNavigationDirection = .forward
    var submissionsObserver: ManagedObjectsObserver<Submission, String>!
}


extension SubmissionPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        return nextPage
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        return previousPage
    }
}


extension SubmissionPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        if pendingViewControllers.first == nextPage {
            navigationDirection = .forward
            print("Forward")
        } else {
            navigationDirection = .reverse
            print("Reverse")
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            switch navigationDirection {
            case .forward:
                previousPage = currentPage.value
                currentPage.value = nextPage
                nextPage = (nextPage?.iterator?.next).map(self.createViewController)
            case .reverse:
                nextPage = currentPage.value
                currentPage.value = previousPage
                previousPage = (previousPage?.iterator?.previous).map(self.createViewController)
            }
        }
    }
}
