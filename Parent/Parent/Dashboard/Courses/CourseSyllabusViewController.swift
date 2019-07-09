//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import CanvasCore
import CanvasCore


import ReactiveSwift
import CanvasCore

class CourseSyllabusViewController: UIViewController {

    @objc let courseID: String
    @objc let studentID: String
    @objc let session: Session
    @objc let whizzyWigView: WhizzyWigView
    internal var refresher: Refresher?
    
    fileprivate var course: Course?

    @objc init(courseID: String, studentID: String, session: Session) {
        self.courseID = courseID
        self.studentID = studentID
        self.session = session
        whizzyWigView = WhizzyWigView(frame: .zero)
        whizzyWigView.scrollView.isScrollEnabled = true
        
        do {
            self.refresher = try Course.airwolfRefresher(session, studentID: studentID, courseID: courseID)
        } catch let error as NSError {
            self.refresher = nil
            ErrorReporter.reportError(error)
        }
        
        super.init(nibName: nil, bundle: nil)

        whizzyWigView.contentInsets = UIEdgeInsets(top: 5.0, left: 15.0, bottom: 5.0, right: 15.0)
        whizzyWigView.useAPISafeLinks = false

        session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .course)).observe(on: UIScheduler()).startWithValues { next in
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
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[whizzy]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["whizzy": whizzyWigView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[whizzy]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["whizzy": whizzyWigView]))
        
        configureRefresher()
        
        refresher?.refresh(false)
    
    }
    @objc func configureRefresher() {
        guard let r = refresher else { return }
        
        r.refreshControl.addTarget(self, action: #selector(CourseSyllabusViewController.refresh), for: UIControl.Event.valueChanged)
        
        whizzyWigView.scrollView.addSubview(r.refreshControl)
        
        r.refreshingCompleted.observeValues { [weak self] error in
            if let me = self, let error = error {
                Router.sharedInstance.defaultErrorHandler()(me, error)
            }
        }
    }
    
    @objc internal func refresh() {
        refresher?.refresh(true)
    }
}
