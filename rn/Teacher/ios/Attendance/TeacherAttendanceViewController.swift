//
//  TeacherAttendanceViewController.swift
//  Teacher
//
//  Created by Derrick Hathaway on 7/28/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import CanvasKeymaster
import AttendanceLE

class TeacherAttendanceViewController: AttendanceViewController {
    
    let courseColor: UIColor
    
    init(courseName: String, courseColor: UIColor, launchURL: URL, courseID: String, date: Date) {
        self.courseColor = courseColor
        super.init(client: CanvasKeymaster.the().currentClient, launchURL: launchURL, courseID: courseID, date: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.barTintColor = courseColor
        navigationController?.navigationBar.isTranslucent = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}
