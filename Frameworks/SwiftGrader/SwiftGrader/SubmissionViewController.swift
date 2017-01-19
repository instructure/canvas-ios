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
        return collection[IndexPath(row: index, section: 0)]
    }
    
    var next: GradingIterator {
        return GradingIterator(collection: collection, index: (index + 1) % collection.count)
    }
    
    var previous: GradingIterator {
        return GradingIterator(collection: collection, index: (index + collection.count - 1) % collection.count)
    }
}

private let formatDate = DateFormatter.LongStyleDateFormatter.string(from:)

extension Session {
    func rac_loadAvatar(_ url: URL?) -> SignalProducer<UIImage?, NSError> {
        guard let url = url else { return SignalProducer(value: .icon(.user)) }
        
        let request = URLRequest(url: url as URL)
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
            .observe(on: UIScheduler())
        
        submittedDate.rac_text <~ submission.producer
            .map { $0?.submittedAt.map(formatDate) ?? "No Submission" }
            .observe(on: UIScheduler())
        
        avatar.rac_image <~ enrollment.producer
            .map { $0?.user?.avatarURL }
            .flatMap(.latest) { url in
                self.session.rac_loadAvatar(url)
            }
            .flatMapError { _ in .empty }
            .observe(on: UIScheduler())
        
        grade.rac_text <~ submission.producer.map { $0?.grade ?? "--" }
    }
    
    func toggleGradeView() {
        
    }
    
    func observeSubmission(_ submission: SignalProducer<Submission?, NoError>, iterator: GradingIterator, assignment: Assignment, inSession session: Session) {
        self.session = session
        self.assignment = assignment
        self.submission <~ submission
        self.iterator = iterator
    }
}
