//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine
import Core
import Foundation

final class DashboardViewModel: ObservableObject {
    // MARK: - Outputs

    @Published public private(set) var state: InstUI.ScreenState = .data(loadingOverlay: false)
    @Published public private(set) var title: String = "Welcome back, Justine"
    @Published public private(set) var programName: String = ""
    @Published public private(set) var progressString: String = "75%"
    @Published public private(set) var progress: Double = 0.75

    @Published public private(set) var currentModule: Module?
    @Published public private(set) var upcomingModules: [Module] = []

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        unowned let unownedSelf = self

        ReactiveStore(useCase: GetCourses())
            .getEntities()
            .replaceError(with: [])
            .compactMap { $0.first }
            .flatMap { course in
                ReactiveStore(
                    useCase: GetModules(courseID: course.id)
                )
                .getEntities()
                .replaceError(with: [])
                .map { (course, $0) }
            }
            .sink(receiveValue: { (course, modules) in
                unownedSelf.programName = course.name ?? ""
                var modules = modules

                if !modules.isEmpty {
                    let currentModule = modules.removeFirst()
                    unownedSelf.currentModule = currentModule
                    unownedSelf.upcomingModules = modules
                }
            })
            .store(in: &subscriptions)
    }
}

extension Module: @retroactive Identifiable {}
