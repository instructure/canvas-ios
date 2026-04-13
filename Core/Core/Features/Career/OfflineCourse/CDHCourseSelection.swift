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
import Foundation

public final class CDHCourseSelection: NSManagedObject, SizeStringConvertible {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var size: String
    @NSManaged public var files: Set<CDHCourseSelectionFile>

    // MARK: - Save

    @discardableResult
    static func save(
        apiEntity: GetHCourseSelectionResponse.Enrollment,
        isBugReport: Bool = false,
        in context: NSManagedObjectContext
    ) -> CDHCourseSelection {

        let course = apiEntity.course

        let entity: CDHCourseSelection = context.first(
            where: #keyPath(CDHCourseSelection.id),
            equals: course.id
        ) ?? context.insert()

        entity.id = course.id
        entity.name = course.name

        let files = extractFiles(from: course)
        entity.size = calculateFormattedSize(from: files)

        if !files.isEmpty {
            entity.files = Set(
                files.map {
                    CDHCourseSelectionFile.save(
                        courseID: course.id,
                        file: $0,
                        in: context
                    )
                }
            )
        }

        return entity
    }
}

// MARK: - Helpers

private extension CDHCourseSelection {
    typealias File = GetHCourseSelectionResponse.Content
    typealias Course = GetHCourseSelectionResponse.Course

    static func extractFiles(from course: Course) -> [File] {
        course.modulesConnection.edges
            .flatMap { $0.node.moduleItems }
            .compactMap { $0.content }
            .filter { $0.id != nil }
    }

    static func calculateFormattedSize(from files: [File]) -> String {
        let totalBytes: Double

        if files.isEmpty {
            totalBytes = 100_000 // fallback
        } else {
            totalBytes = files
                .map { $0.size ?? "" }
                .reduce(0) { $0 + bytes(from: $1) }
        }
        return format(bytes: totalBytes)
    }

    static func format(bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

protocol SizeStringConvertible {
    static func bytes(from sizeString: String) -> Double
}
extension SizeStringConvertible {
    static func bytes(from sizeString: String) -> Double {
        let components = sizeString.split(separator: " ")
        guard components.count == 2,
              let value = Double(components[0]) else { return 0 }

        switch components[1].uppercased() {
        case "B":  return value
        case "KB": return value * 1_000
        case "MB": return value * 1_000_000
        case "GB": return value * 1_000_000_000
        default:   return 0
        }
    }
}
