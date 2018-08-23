//
// Copyright (C) 2018-present Instructure, Inc.
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

public class GetCourses: GroupOperation {
    let database: Database
    var errors: [Error] = []

    init(api: API = URLSessionAPI(), database: Database) {
        self.database = database
        super.init()
        let request = GetCoursesRequest(includeUnpublished: true)
        let fetch = APIOperation(api: api, request: request)
        let persist = DependencyOperation(fetch) { [weak self] fetch in
            if let error = fetch.error {
                self?.errors.append(error)
                return
            }
            if let courses = fetch.response {
                self?.writeCourses(courses)
            }
        }

        addOperations([fetch, persist])
    }

    func writeCourses(_ courses: [APICourse]) {
        database.performBackgroundTask { [weak self] client in
            // Keep track of the local courses that need to be removed
            var existing: [Course] = client.fetch()

            for course in courses {
                let predicate = NSPredicate(format: "%K == %@", "id", course.id)
                let c: Course = client.fetch(predicate).first ?? client.insert()
                c.id = course.id
                c.name = course.name

                if let index = existing.index(of: c) {
                    existing.remove(at: index)
                }
            }

            // Delete courses that no longer exist
            for course in existing {
                client.delete(course)
            }

            do {
                try client.save()
            } catch {
                self?.errors.append(error)
            }

            self?.finish()
        }
    }
}
