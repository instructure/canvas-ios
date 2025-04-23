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

#if DEBUG
import Core
import Combine

final class ModuleItemSequenceInteractorPreview: ModuleItemSequenceInteractor {
    func fetchModuleItems(
        assetId: String,
        moduleID: String?,
        itemID: String?,
        ignoreCache: Bool
    ) -> AnyPublisher<(HModuleItemSequence?, HModuleItem?), Never> {
        let moduleItem = HModuleItem(id: "14", title: "Sub title 2", htmlURL: nil)
        let currentModuleItem = HModuleItemSequenceNode(id: "212", moduleID: "1000")
        let nextModuleItem = HModuleItemSequenceNode(id: "212", moduleID: "1000")
        let perviousModuleItem = HModuleItemSequenceNode(id: "212", moduleID: "1000")
        let moduleItemSequence = HModuleItemSequence(
            moduleID: "11",
            itemID: "222",
            next: nextModuleItem,
            previous: perviousModuleItem,
            current: currentModuleItem
        )

        return Just((moduleItemSequence, moduleItem))
            .eraseToAnyPublisher()
    }

    func markAsViewed(moduleID: String, itemID: String) -> AnyPublisher<[HModuleItem], Error> {
        Just([HModuleItem(id: "14", title: "Sub title 2", htmlURL: nil)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func markAsDone(completed: Bool, moduleID: String, itemID: String) -> AnyPublisher<[HModuleItem], Error> {
        Just([HModuleItem(id: "14", title: "Sub title 2", htmlURL: nil)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func setOfflineMode(assetID: String) -> String? {
        nil
    }

    func getCourse() -> AnyPublisher<HCourse, Never> {
        Just(HCourse(id: "", name: "", overviewDescription: "", modules: []))
            .eraseToAnyPublisher()
    }
}
#endif
