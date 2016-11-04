//
//  GradeSubmissionViewController.swift
//  SwiftGrader
//
//  Created by Derrick Hathaway on 10/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import Peeps
import SoPersistent
import AssignmentKit
import TooLegit
import SoIconic

class GradingIterator {
    let collection: FetchedCollection<UserEnrollment>
    let index: Int
    
    init(collection: FetchedCollection<UserEnrollment>, index: Int = 0) {
        self.collection = collection
        self.index = index
        
        // TODO: make sure our index tracks the current item
        // after inserts/deletes
    }
    
    var enrollment: UserEnrollment {
        return collection[NSIndexPath(forRow: index, inSection: 0)]
    }
    
    var next: GradingIterator {
        return GradingIterator(collection: collection, index: (index + 1) % collection.count)
    }
    
    var previous: GradingIterator {
        return GradingIterator(collection: collection, index: (index + collection.count - 1) % collection.count)
    }
}

private let formatDate = NSDateFormatter.LongStyleDateFormatter.stringFromDate

extension Session {
    func rac_loadAvatar(url: NSURL?) -> SignalProducer<UIImage?, NSError> {
        guard let url = url else { return SignalProducer(value: .icon(.user)) }
        
        let request = NSURLRequest(URL: url)
        return rac_dataWithRequest(request)
            .map { (data, response) in
                return UIImage(data: data) ?? .icon(.user)
            }
    }
}

class SubmissionViewController: UIViewController {
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var submittedDate: UILabel!
    @IBOutlet weak var gradePicker: GradePicker!
    
    var session: Session!
    var assignment: Assignment!
    
    var iterator: GradingIterator? {
        didSet {
            enrollment.value = iterator?.enrollment
        }
    }
    
    let enrollment = MutableProperty<UserEnrollment?>(nil)
    let submission = MutableProperty<Submission?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatar.layer.cornerRadius = 20.0
        avatar.clipsToBounds = true
        
        studentName.rac_text <~ enrollment.producer
            .map { $0?.user?.name ?? "" }
            .observeOn(UIScheduler())
        
        submittedDate.rac_text <~ submission.producer
            .map { $0?.submittedAt.map(formatDate) ?? "No Submission" }
            .observeOn(UIScheduler())
        
        avatar.rac_image <~ enrollment.producer
            .map { $0?.user?.avatarURL }
            .flatMap(.Latest) { url in
                self.session.rac_loadAvatar(url)
            }
            .flatMapError { _ in .empty }
            .observeOn(UIScheduler())
        
        grade.rac_text <~ submission.producer.map { $0?.grade ?? "--" }
    }
    
    func toggleGradeView() {
        
    }
    
    func observeSubmission(submission: SignalProducer<Submission?, NoError>, iterator: GradingIterator, assignment: Assignment, inSession session: Session) {
        self.session = session
        self.assignment = assignment
        self.submission <~ submission
        self.iterator = iterator
    }
}
