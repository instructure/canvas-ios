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
import mobile_offline_downloader_ios

final class CourseStorageDataModel {

    var course: Course

    var courseId: String {
        course.id
    }

    init(course: Course) {
        self.course = course
    }

    static func configureId(id: String) -> String {
        "\(id)_download_course"
    }
}

extension CourseStorageDataModel: OfflineStorageDataProtocol {
    static func fromOfflineModel(_ model: OfflineStorageDataModel) throws -> CourseStorageDataModel {
        if model.type == OfflineContentType.downloadcourse.rawValue {
            let env = AppEnvironment.shared
            let data = model.json.data(using: .utf8)
            let dictionary = (try? JSONSerialization.jsonObject(with: data!) as? [String: Any]) ?? [:]
            let context = env.database.viewContext
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), model.id)
            let course: Course = context.fetch(predicate).first ?? context.insert()
            let downloadCourse = CourseStorageDataModel(course: course)

            if let jsonString = dictionary["course"] as? String,
                let data = jsonString.data(using: String.Encoding.utf8),
                let dictionary = try JSONSerialization.jsonObject(
                with: data,
                options: .mutableContainers
               ) as? [String: Any] {

                if let accessRestrictedByDate = dictionary["accessRestrictedByDate"] as? Bool {
                    downloadCourse.course.accessRestrictedByDate = accessRestrictedByDate
                }

                if let bannerImageDownloadURL = dictionary["bannerImageDownloadURL"] as? String {
                    downloadCourse.course.bannerImageDownloadURL = URL(string: bannerImageDownloadURL)
                }

                if let canCreateAnnouncement = dictionary["canCreateAnnouncement"] as? Bool {
                    downloadCourse.course.canCreateAnnouncement = canCreateAnnouncement
                }

                if let courseCode = dictionary["courseCode"] as? String {
                    downloadCourse.course.courseCode = courseCode
                }

                if let courseColor = dictionary["courseColor"] as? String {
                    downloadCourse.course.courseColor = courseColor
                }

                if let defaultViewRaw = dictionary["defaultViewRaw"] as? String {
                    downloadCourse.course.defaultViewRaw = defaultViewRaw
                }

                if let hideFinalGrades = dictionary["hideFinalGrades"] as? Bool {
                    downloadCourse.course.hideFinalGrades = hideFinalGrades
                }

                if let id = dictionary["id"] as? String {
                    downloadCourse.course.id = id
                }

                if let imageDownloadURL = dictionary["imageDownloadURL"] as? String {
                    downloadCourse.course.imageDownloadURL = URL(string: imageDownloadURL)
                }

                if let isCourseDeleted = dictionary["isCourseDeleted"] as? Bool {
                    downloadCourse.course.isCourseDeleted = isCourseDeleted
                }

                if let isFavorite = dictionary["isFavorite"] as? Bool {
                    downloadCourse.course.isFavorite = isFavorite
                }

//                if let isFutureEnrollment = dictionary["isFutureEnrollment"] as? Bool {
//                    downloadCourse.course.isFutureEnrollment = isFutureEnrollment
//                }

                if let isHomeroomCourse = dictionary["isHomeroomCourse"] as? Bool {
                    downloadCourse.course.isHomeroomCourse = isHomeroomCourse
                }

                if let isPastEnrollment = dictionary["isPastEnrollment"] as? Bool {
                    downloadCourse.course.isPastEnrollment = isPastEnrollment
                }

                if let isPublished = dictionary["isPublished"] as? Bool {
                    downloadCourse.course.isPublished = isPublished
                }

                if let name = dictionary["name"] as? String {
                    downloadCourse.course.name = name
                }

                if let syllabusBody = dictionary["syllabusBody"] as? String {
                    downloadCourse.course.syllabusBody = syllabusBody
                }

                if let termName = dictionary["termName"] as? String {
                    downloadCourse.course.termName = termName
                }
            }
            return downloadCourse
        }
        throw OfflineStorageDataError.cantCreateObject(type: ModuleItem.self)
    }

    func toOfflineModel() throws -> OfflineStorageDataModel {
        guard let courseJSON = try? course.toOfflineModel().json else {
            return OfflineStorageDataModel(id: "", type: "", json: "")
        }
        let dictionary: [String: Any] = [
            "course": courseJSON
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return OfflineStorageDataModel(
                id: CourseStorageDataModel.configureId(id: course.id),
                type: OfflineContentType.downloadcourse.rawValue,
                json: jsonString
            )
        }
        return OfflineStorageDataModel(id: "", type: "", json: "")
    }
}
