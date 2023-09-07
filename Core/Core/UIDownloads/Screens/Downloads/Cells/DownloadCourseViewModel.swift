//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

final class DownloadCourseViewModel: Identifiable, Hashable {
    var id: String {
        courseId
    }

    static func == (lhs: DownloadCourseViewModel, rhs: DownloadCourseViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let courseDataModel: CourseStorageDataModel

    var course: Course? {
        courseDataModel.course
    }

    var courseId: String {
        course?.id ?? "-1"
    }

    var name: String {
        course?.name ?? ""
    }

    var courseCode: String {
        course?.courseCode ?? ""
    }

    var termName: String {
        course?.termName ?? ""
    }

    var imageURL: URL? {
        guard let imageDownloadURL = course?.imageDownloadURL else {
            return nil
        }
        return imageDownloadURL
    }

    var color: UIColor {
        UIColor(hexString: course?.courseColor) ?? .ash
    }

    var textColor: UIColor {
        UIColor(hexString: course?.courseColor) ?? .textDarkest
    }

    init(courseDataModel: CourseStorageDataModel) {
        self.courseDataModel = courseDataModel
    }
}
