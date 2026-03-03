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

import Core
import Foundation

protocol LearningLibraryItemNavigating {
    var router: Router { get }

    func navigateToLearningLibraryItem(
        _ model: LearningLibraryCardModel,
        from viewController: WeakViewController
    )
}

extension LearningLibraryItemNavigating {
    func navigateToLearningLibraryItem(
        _ model: LearningLibraryCardModel,
        from viewController: WeakViewController
    ) {
        switch model.itemType {
        case .course:
            guard let enrollmentId = model.courseEnrollmentId else {
                return
            }
            router.show(
                CourseDetailsAssembly.makeCourseDetailsViewController(
                    courseID: model.courseID,
                    enrollmentID: enrollmentId
                ),
                from: viewController
            )
        case .program:
            router.show(
                ProgramDetailsAssembly.makeViewController(programID: ""),
                from: viewController
            )
        default:
            navigateToItemSequence(model: model, viewController: viewController)
        }
    }

    private func navigateToItemSequence(
         model: LearningLibraryCardModel,
         viewController: WeakViewController
     ) {

         guard let baseURL = model.canvasUrl, let itemID = model.moduleItemID else { return }
         let courseID = model.courseID

         let url = baseURL.appendingPathComponent("courses")
             .appendingPathComponent(courseID)
             .appendingPathComponent("modules")
             .appendingPathComponent("items")
             .appendingPathComponent(itemID)

         let moduleItem = HModuleItem(
             id: itemID,
             title: model.name,
             htmlURL: url,
             isCompleted: false
         )
         router.route(to: url, userInfo: ["moduleItem": moduleItem], from: viewController)
     }
}
