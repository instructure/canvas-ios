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
import CanvasKit
import AttendanceLE

private let user = CKIUser(fromJSONDictionary: [
    "id": 5356213,
    "name": "Ivy Iversen",
    "short_name": "Ivy Iversen",
    "sortable_name": "Iversen, Ivy",
    "avatar_url": "https://mobiledev.instructure.com/files/87973393/download?download_frd=1&verifier=oMg2q5Y5A28gvrGmghQ97luihfCunrLyVEJwctdY",
    "primary_email": "derrick+ivy@instructure.com",
    "login_id": "ivy",
    "lti_user_id": "ceaaa8c6517e7616a53e57dfd147f67b2346635c"
])

private let ivy: CKIClient! = {
    let client = CKIClient(baseURL: URL(string: "https://mobiledev.instructure.com/"), token: "1~bmCAOXYdwgFpDQtwaHTGeOnYsEHECEMg5arLbwJlbL9EtWBN2hy8g80Gn6v0ZQGi")
    client?.setValue(user, forKeyPath: "currentUser")
    return client
}()

class StagingViewController: UITableViewController {
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            // we need an LTI Launch URL before we can do the teacher view
            ivy.fetchTabs(for: CKICourse(id: "24219")).subscribeNext { [weak ivy] (tabs) in
                guard let tabs = tabs as? [CKITab] else { return }
                
                // TODO: match the attendance tool "correctly" somehow
                if let attendanceURL = tabs
                    .filter({ $0.label == "Attendance" })
                    .first
                    .flatMap({ $0.url }) {
                    
                    guard let ivy = ivy else { return }
                    
                    let attendance = AttendanceViewController(client: ivy, launchURL: attendanceURL, courseID: "24219", date: Date())
                    
                    self.navigationController?.pushViewController(attendance, animated: true)
                }
            }
            
        }
    }
}
