//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit
import AssignmentKit
import SoPersistent
import TooLegit
import SoLazy
import ReactiveCocoa
import Result
import EnrollmentKit
import SoPretty

protocol DetailCell {
    var paddingConstraints: [NSLayoutConstraint]! { get }
}

class AssignmentDetailViewController: Assignment.DetailViewController {
    
    static func new(session: Session, courseID: String, assignmentID: String) throws -> AssignmentDetailViewController {
        
        guard let me = UIStoryboard(name: "AssignmentDetailViewController", bundle: nil).instantiateInitialViewController() as? AssignmentDetailViewController else { ❨╯°□°❩╯⌢"Storyboard fail!" }
        
        
        let enrollmentsSource = session.enrollmentsDataSource
        let colorProducer: SignalProducer<UIColor, NoError> = enrollmentsSource.producer(ContextID(id: courseID, context: .Course))
            .map { $0?.color ?? .prettyGray() }
            .flatMapError { _ in return SignalProducer.empty }
        
        me.prepare(try Assignment.observer(session, courseID: courseID, assignmentID: assignmentID), refresher: try Assignment.refresher(session, courseID: courseID, assignmentID: assignmentID), detailsFactory: AssignmentDetail.details(session.baseURL, color: colorProducer))
        
        me.title = me.observer?.object?.name
        let titleSignal: Signal<String?, NSError> = me.observer.signal
            .map { $0.1?.name }
        let producer: SignalProducer<String?, NoError> = SignalProducer(signal: titleSignal)
            .flatMapError { _ in SignalProducer.empty }
        me.rac_title <~ producer
        
        return me
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for cell in tableView.visibleCells.flatMap({$0 as? DetailCell}) {
            cell.paddingConstraints.forEach { $0.constant = self.traitCollection.detailPadding }
        }
    }
}