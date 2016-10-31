//
//  CourseSyllabusViewController.swift
//  Parent
//
//  Created by Ben Kraus on 3/17/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import WhizzyWig
import EnrollmentKit
import TooLegit
import SoPersistent
import ReactiveCocoa
import SoLazy

class CourseSyllabusViewController: UIViewController {

    let courseID: String
    let studentID: String
    let session: Session
    let whizzyWigView: WhizzyWigView
    internal var refresher: Refresher?
    
    private var course: Course?

    init(courseID: String, studentID: String, session: Session) {
        self.courseID = courseID
        self.studentID = studentID
        self.session = session
        whizzyWigView = WhizzyWigView(frame: CGRectZero)
        whizzyWigView.scrollView.scrollEnabled = true
        
        do {
            self.refresher = try Course.airwolfRefresher(session, studentID: studentID, courseID: courseID)
        } catch let error as NSError {
            self.refresher = nil
            error.report()
        }
        
        super.init(nibName: nil, bundle: nil)

        whizzyWigView.contentInsets = UIEdgeInsets(top: 5.0, left: 15.0, bottom: 5.0, right: 15.0)
        whizzyWigView.useAPISafeLinks = false

        session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .Course)).observeOn(UIScheduler()).startWithNext { next in
            guard let course = next as? Course else { return }
            self.whizzyWigView.loadHTMLString(course.syllabusBody ?? "", baseURL: session.baseURL)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        whizzyWigView.frame = view.bounds
        view.addSubview(whizzyWigView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[whizzy]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["whizzy": whizzyWigView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[whizzy]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["whizzy": whizzyWigView]))
        
        configureRefresher()
        
        refresher?.refresh(false)
    }
    
    func configureRefresher() {
        guard let r = refresher else { return }
        
        r.refreshControl.addTarget(self, action: #selector(CourseSyllabusViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        
        whizzyWigView.scrollView.addSubview(r.refreshControl)
        
        r.refreshingCompleted.observeNext { [weak self] error in
            if let me = self, let error = error {
                error.presentAlertFromViewController(me)
            }
        }
    }
    
    internal func refresh() {
        refresher?.refresh(true)
    }
}
