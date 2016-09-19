//
//  AssignmentDetailViewController.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
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