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

final public class CDHLearningLibraryCollectionItem: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var completionPercentage: Double
    @NSManaged public var displayOrder: NSNumber
    @NSManaged public var estimatedDurationMinutes: NSNumber?
    @NSManaged public var imageUrl: String?
    @NSManaged public var isBookmarked: Bool
    @NSManaged public var isEnrolledInCanvas: Bool
    @NSManaged public var itemId: String
    @NSManaged public var itemType: String
    @NSManaged public var libraryId: String
    @NSManaged public var moduleCount: NSNumber?
    @NSManaged public var moduleItemCount: NSNumber?
    @NSManaged public var name: String
    @NSManaged public var programCourseId: String?
    @NSManaged public var programId: String?
    @NSManaged public var canvasEnrollmentId: String?

    @discardableResult
     public static func save(
          _ apiEntity: LearningLibraryItemsResponse,
          in context: NSManagedObjectContext
     ) -> CDHLearningLibraryCollectionItem {
         let dbEntity: CDHLearningLibraryCollectionItem = context.first(
             where: #keyPath(CDHLearningLibraryCollectionItem.id),
             equals: apiEntity.id
         ) ?? context.insert()

         dbEntity.id = apiEntity.id
         dbEntity.completionPercentage = Double(apiEntity.completionPercentage.defaultToZero)
         dbEntity.displayOrder = apiEntity.displayOrder.defaultToZero as NSNumber
         dbEntity.estimatedDurationMinutes = apiEntity.canvasCourse?.estimatedDurationMinutes as NSNumber?
         dbEntity.imageUrl = apiEntity.canvasCourse?.courseImageUrl
         dbEntity.isBookmarked = apiEntity.isBookmarked.defaultToFalse
         dbEntity.isEnrolledInCanvas = apiEntity.isEnrolledInCanvas.defaultToFalse
         dbEntity.itemId = (apiEntity.canvasCourse?.courseId).defaultToEmpty
         dbEntity.itemType = apiEntity.itemType
         dbEntity.libraryId = apiEntity.libraryId.defaultToEmpty
         if let moduleCount = apiEntity.canvasCourse?.moduleCount, moduleCount > 0 {
             dbEntity.moduleCount = NSNumber(value: moduleCount)
         } else {
             dbEntity.moduleCount = nil
         }
         if let moduleItemCount = apiEntity.canvasCourse?.moduleItemCount, moduleItemCount > 0 {
             dbEntity.moduleItemCount = NSNumber(value: moduleItemCount)
         } else {
             dbEntity.moduleItemCount = nil
         }
         dbEntity.name = (apiEntity.canvasCourse?.courseName).defaultToEmpty
         dbEntity.programCourseId = apiEntity.programCourseId.defaultToEmpty
         dbEntity.programId = apiEntity.programId.defaultToEmpty
         dbEntity.canvasEnrollmentId = apiEntity.canvasEnrollmentId
         return dbEntity
     }
}

extension CDHLearningLibraryCollectionItem {
    @discardableResult
     public static func updateBookmark(
          _ id: String,
          isBookmarked: Bool = false,
          in context: NSManagedObjectContext
     ) -> CDHLearningLibraryCollectionItem {
         let dbEntity: CDHLearningLibraryCollectionItem = context.first(
             where: #keyPath(CDHLearningLibraryCollectionItem.id),
             equals: id
         ) ?? context.insert()
         dbEntity.isBookmarked = isBookmarked
         return dbEntity
     }
}
