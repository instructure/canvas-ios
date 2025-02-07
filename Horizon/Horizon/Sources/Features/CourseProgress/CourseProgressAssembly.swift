//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct CourseProgressAssembly {

    static func makeView(
        course: HCourse,
        currentModuleItem: HModuleItem?,
        onSelectModuleItem: ((HModuleItem?) -> Void)?
    ) -> UIViewController {
        let environment = AppEnvironment.shared
        let viewModel = CourseProgressViewModel(
            router: environment.router,
            course: course,
            currentModuleItem: currentModuleItem,
            onSelectModuleItem: onSelectModuleItem
        )
        let view = CourseProgressView(viewModel: viewModel)
        let viewController = CoreHostingController(view)
        if let presentationController = viewController.sheetPresentationController {
            presentationController.detents = [.large()]
            presentationController.preferredCornerRadius = 32
        }
        return viewController
    }

    static func makeViewPreview() -> CourseProgressView {
        let moduleItems: [HModuleItem] = [
            .init(id: "10", title: "AI Section", htmlURL: nil, type: .file(""), moduleID: "100"),
            .init(id: "12", title: "AI Section Demo", htmlURL: nil, type: .file(""), moduleID: "100")
        ]
        let modules = [
            HModule(
                id: "100",
                name: "Inro for AI",
                courseID: "1060",
                items: moduleItems,
                state: .completed,
                lockMessage: nil,
                countOfPrerequisite: 1
            )
        ]
        let course = HCourse(
            id: "10",
            institutionName: "Instructure",
            name: "AI for Everyone course",
            overviewDescription: "overview Description",
            modules: modules
        )
       let viewModel = CourseProgressViewModel(
            router: AppEnvironment.shared.router,
            course: course,
            currentModuleItem: moduleItems.first
       ) { _ in }
        return CourseProgressView(viewModel: viewModel)
    }
}
