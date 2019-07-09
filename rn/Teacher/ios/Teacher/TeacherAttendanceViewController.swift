//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import Foundation
import CanvasKeymaster
import CanvasCore

class TeacherAttendanceViewController: AttendanceViewController {
    
    @objc let courseColor: UIColor
    
    @objc init(courseName: String, courseColor: UIColor, launchURL: URL, courseID: String, date: Date) throws {
        self.courseColor = courseColor
        guard let client = CanvasKeymaster.the().currentClient else { throw NSError(subdomain: "com.instructure.Teacher", description: "Keymaster client is nil") }
        super.init(client: client, launchURL: launchURL, courseID: courseID, date: Date())
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
