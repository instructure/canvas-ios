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

import Combine
import Core

protocol ModuleItemStateInteractor {
    func getModuleItemState(
        sequence: HModuleItemSequence?,
        item: HModuleItem?,
        moduleID: String?,
        itemID: String?
    ) -> ModuleItemSequenceViewState?
}

final class ModuleItemStateInteractorLive: ModuleItemStateInteractor {
    typealias AssetType = GetModuleItemSequenceRequest.AssetType

    // MARK: - Dependencies

    private let environment: AppEnvironment
    private let courseID: String
    private let url: URLComponents
    private let assetType: AssetType

    // MARK: - Init

    init(
        environment: AppEnvironment,
        courseID: String,
        url: URLComponents,
        assetType: AssetType
    ) {
        self.environment = environment
        self.courseID = courseID
        self.url = url
        self.assetType = assetType
    }

    func getModuleItemState(
        sequence: HModuleItemSequence?,
        item: HModuleItem?,
        moduleID: String?,
        itemID: String?
    ) -> ModuleItemSequenceViewState? {
        guard let url = url.url else { return nil }
        if sequence?.current != nil {
            return getModuleItemDetailsState(item: item, moduleID: moduleID, itemID: itemID)
        } else if assetType != .moduleItem, let match = environment.router.match(url.appendingOrigin("module_item_details")) {
            return .moduleItem(controller: match, id: item?.url?.absoluteString ?? "")
        } else {
            return .externalURL(
                url: url,
                environment: environment,
                name: String(localized: "Unsupported Item", bundle: .horizon),
                courseID: courseID
            )
        }
    }

   private func getModuleItemDetailsState(
        item: HModuleItem?,
        moduleID: String?,
        itemID: String?
    ) -> ModuleItemSequenceViewState? {
        guard let item else { return nil }

        let showLocked = item.visibleWhenLocked != true && item.lockedForUser == true
        if showLocked {
            return .locked(title: item.title, lockExplanation: item.lockExplanation ?? "")
        }

        switch item.type {
        case .externalURL(let url):
            return .externalURL(url: url, environment: environment, name: item.title, courseID: item.courseID)
        case let .externalTool(toolID, url):
            let tools = LTITools(
                env: environment,
                context: .course(courseID),
                id: toolID,
                url: url,
                launchType: .module_item,
                isQuizLTI: item.isQuizLTI,
                moduleID: moduleID,
                moduleItemID: itemID
            )
            return .externalTool(tools: tools, name: item.title)

        case .assignment(let id):
            return .assignment(courseID: courseID, assignmentID: id)
        default:
            guard let url = item.url else { return nil }
            let preparedURL = url.appendingOrigin("module_item_details")
            let itemViewController = environment.router.match(preparedURL)
            if let itemViewController, let routeTemplate = environment.router.template(for: preparedURL) {
                RemoteLogger.shared.logBreadcrumb(route: routeTemplate, viewController: itemViewController)
            }
            if let itemViewController {
                return .moduleItem(controller: itemViewController, id: url.absoluteString)
            }
            return nil
        }
    }
}
