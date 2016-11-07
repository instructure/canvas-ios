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
import TooLegit
import Peeps
import SoPersistent
import AssignmentKit
import ReactiveCocoa
import Result

public class GradingNavigationViewController: UIViewController {
    public static func present(from: UIViewController, for assignmentID: String, in context: ContextID, with session: Session) throws {

        let story = UIStoryboard(name: "GradingNavigation", bundle: .swiftGrader)
        let nav = story.instantiateInitialViewController() as! UINavigationController
        
        let gradingNav = nav.topViewController as! GradingNavigationViewController
        try gradingNav.prepare(for: assignmentID, in: context, with: session)
        
        from.presentViewController(nav, animated: true, completion: nil)
    }
    
    var assignmentObserver: ManagedObjectObserver<Assignment>!
    
    var enrollmentsObserver: ManagedObjectsObserver<UserEnrollment, String>!
    var enrollmentsRefresher: Refresher?
    var enrollmentsRefreshErrorsDisposable: Disposable?
    
    var submissionsObserver: ManagedObjectsObserver<Submission, String>!
    var submissionsRefresher: Refresher?
    var submissionsRefreshErrorsDisposable: Disposable?
    
    var session: Session!
    
    func prepare(for assignmentID: String, in context: ContextID, with session: Session) throws {
        assignmentObserver = try Assignment.observer(session, courseID: context.id, assignmentID: assignmentID)
        self.session = session
        
        // Students
        
        let peepsContext = try session.peepsManagedObjectContext()
        let enrollments = try UserEnrollment.collection(enrolledIn: context, as: .Student, for: session)
        enrollmentsObserver = ManagedObjectsObserver<UserEnrollment, String>(context: peepsContext, collection: enrollments) { $0.user?.id ?? "" }
        
        enrollmentsRefresher = try UserEnrollment.refresher(enrolledIn: context, for: session)
        enrollmentsRefreshErrorsDisposable = enrollmentsRefresher?.refreshingCompleted
            .observeOn(UIScheduler())
            .observeNext { [weak self] error in
                guard let me = self, err = error else { return }
                err.report(false, alertUserFrom: me)
            }.map(ScopedDisposable.init)
        enrollmentsRefresher?.refresh(true)
        
        // Submissions

        let assignmentsContext = try session.assignmentsManagedObjectContext()
        let submissions = try Submission.studentSubmissionsCollection(session, courseID: context.id, assignmentID: assignmentID)
        submissionsObserver = ManagedObjectsObserver<Submission, String>(context: assignmentsContext, collection: submissions) { $0.userID ?? "" }
        
        submissionsRefresher = try Submission.studentSubmissionsRefresher(session, courseID: context.id, assignmentID: assignmentID)
        submissionsRefreshErrorsDisposable = submissionsRefresher?.refreshingCompleted
            .observeOn(UIScheduler())
            .observeNext { [weak self] error in
                guard let me = self, err = error else { return }
                err.report(false, alertUserFrom: me)
            }.map(ScopedDisposable.init)
        submissionsRefresher?.refresh(true)
        
        title = assignmentObserver.object?.name
        rac_title <~ assignmentObserver.signal
            .map { (_, assignment) in assignment?.name }
            .flatMapError {_ in .empty }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pager = segue.destinationViewController as? SubmissionPageViewController {
            guard let assignment = assignmentObserver.object else { return }
            pager.loadSubmissions(enrollments: enrollmentsObserver.collection, submissionsObserver: submissionsObserver, assignment: assignment, inSession: session)
        }
    }
    
    
    @IBAction func doneGrading(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func toggleGradeView(sender: AnyObject) {
        
    }
}

