//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData

struct UpdateCourseNickname: APIUseCase {
    typealias Model = Course

    let courseID: String
    let nickname: String

    var cacheKey: String? { nil }
    var request: PutCourseNicknameRequest { PutCourseNicknameRequest(courseID: courseID, nickname: nickname) }

    func write(response: APICourseNickname?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        let course: Course? = client.first(where: #keyPath(Course.id), equals: item.course_id.value)
        course?.name = item.nickname
        let card: DashboardCard? = client.first(where: #keyPath(DashboardCard.id), equals: item.course_id.value)
        card?.shortName = item.nickname
    }
}
