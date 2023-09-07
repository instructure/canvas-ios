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

extension Course: OfflineStorageDataProtocol {
    public static func fromOfflineModel(_ model: OfflineStorageDataModel) throws -> Course {
        let env = AppEnvironment.shared
        if model.type == OfflineContentType.course.rawValue {
            let data = model.json.data(using: .utf8)
            let dictionary = (try? JSONSerialization.jsonObject(with: data!) as? [String: Any]) ?? [:]
            let context = env.database.viewContext
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), model.id)
            let course: Course = context.fetch(predicate).first ?? context.insert()

            if let accessRestrictedByDate = dictionary["accessRestrictedByDate"] as? Bool {
                course.accessRestrictedByDate = accessRestrictedByDate
            }

            if let bannerImageDownloadURL = dictionary["bannerImageDownloadURL"] as? String {
                course.bannerImageDownloadURL = URL(string: bannerImageDownloadURL)
            }

            if let canCreateAnnouncement = dictionary["canCreateAnnouncement"] as? Bool {
                course.canCreateAnnouncement = canCreateAnnouncement
            }

            if let courseCode = dictionary["courseCode"] as? String {
                course.courseCode = courseCode
            }

            if let courseColor = dictionary["courseColor"] as? String {
                course.courseColor = courseColor
            }

            if let defaultViewRaw = dictionary["defaultViewRaw"] as? String {
                course.defaultViewRaw = defaultViewRaw
            }

            if let hideFinalGrades = dictionary["hideFinalGrades"] as? Bool {
                course.hideFinalGrades = hideFinalGrades
            }

            if let id = dictionary["id"] as? String {
                course.id = id
            }

            if let imageDownloadURL = dictionary["imageDownloadURL"] as? String {
                course.imageDownloadURL = URL(string: imageDownloadURL)
            }

            if let isCourseDeleted = dictionary["isCourseDeleted"] as? Bool {
                course.isCourseDeleted = isCourseDeleted
            }

            if let isFavorite = dictionary["isFavorite"] as? Bool {
                course.isFavorite = isFavorite
            }

//            if let isFutureEnrollment = dictionary["isFutureEnrollment"] as? Bool {
//                course.isFutureEnrollment = isFutureEnrollment
//            }

            if let isHomeroomCourse = dictionary["isHomeroomCourse"] as? Bool {
                course.isHomeroomCourse = isHomeroomCourse
            }

            if let isPastEnrollment = dictionary["isPastEnrollment"] as? Bool {
                course.isPastEnrollment = isPastEnrollment
            }

            if let isPublished = dictionary["isPublished"] as? Bool {
                course.isPublished = isPublished
            }

            if let name = dictionary["name"] as? String {
                course.name = name
            }

            if let syllabusBody = dictionary["syllabusBody"] as? String {
                course.syllabusBody = syllabusBody
            }

            if let termName = dictionary["termName"] as? String {
                course.termName = termName
            }

            return course
        }

        throw OfflineStorageDataError.cantCreateObject(type: Course.self)
    }

    public func toOfflineModel() throws -> OfflineStorageDataModel {
        let dictionary: [String: Any] = [
            "accessRestrictedByDate": accessRestrictedByDate,
            "bannerImageDownloadURL": bannerImageDownloadURL?.absoluteString ?? "",
            "canCreateAnnouncement": canCreateAnnouncement,
            "courseCode": courseCode ?? "",
            "courseColor": courseColor ?? "",
            "defaultViewRaw": defaultViewRaw ?? "",
            "hideFinalGrades": hideFinalGrades,
            "id": id,
            "imageDownloadURL": imageDownloadURL?.absoluteString ?? "",
            "isCourseDeleted": isCourseDeleted,
            "isFavorite": isFavorite,
//            "isFutureEnrollment": isFutureEnrollment,
            "isHomeroomCourse": isHomeroomCourse,
            "isPastEnrollment": isPastEnrollment,
            "isPublished": isPublished,
            "name": name ?? "",
            "syllabusBody": syllabusBody ?? "",
            "termName": termName ?? ""
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return OfflineStorageDataModel(
                id: id,
                type: OfflineContentType.course.rawValue,
                json: jsonString
            )
        }

        return OfflineStorageDataModel(id: "", type: "", json: "")
    }
}
