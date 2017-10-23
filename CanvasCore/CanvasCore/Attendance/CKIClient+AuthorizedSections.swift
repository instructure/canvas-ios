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
