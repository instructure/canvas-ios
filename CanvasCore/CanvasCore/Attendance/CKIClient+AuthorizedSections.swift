//
// Copyright (C) 2017-present Instructure, Inc.
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

import Foundation
import CanvasKit
import ReactiveObjC

extension CKIClient {
    func fetchAuthorizedSections(forCourseWithID courseID: String, completed: @escaping ([CKISection], Error?) -> Void) {
        var enrollments: [CKIEnrollment] = []
        
        // /api/v1/courses/<courseID>/enrollments?user_id=<userID>&type[]=TeacherEnrollment&type[]=TaEnrollment
        self.fetchEnrollments(for: CKICourse(id: courseID), ofTypes: ["TeacherEnrollment", "TaEnrollment"], forUserWithID: self.currentUser.id).subscribeNext({ enrollmentsPage in
            guard let page = enrollmentsPage as? [CKIEnrollment] else {
                return
            }
            enrollments += page
        }, error: { error in
            completed([], error)
        }) { [weak self] in
            guard let me = self else { completed([], nil); return }

            // don't fetch sections if the user isn't enrolled in this course as a teacher or ta
            if enrollments.count == 0 {
                completed([], nil)
                return
            }
            
            let atLeast1UnlimitedEnrollment = enrollments
                .first { !$0.limitPrivilegesToCourseSection.boolValue } != nil
            
            let enrolledSectionIDs = Set(enrollments.map { $0.sectionID })
            var availableSections: [CKISection] = []
            me.fetchSections(for: CKICourse(id: courseID)).subscribeNext({ sections in
                guard let newSections = sections as? [CKISection] else {
                    return
                }
                
                availableSections += newSections.filter { s in
                    return atLeast1UnlimitedEnrollment || enrolledSectionIDs.contains(s.id)
                }
            }, error: { error in
                completed([], error)
            }, completed: {
                completed(availableSections, nil)
            })
        }
    }
}
