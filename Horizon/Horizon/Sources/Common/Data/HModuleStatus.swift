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

import HorizonUI
import Core

struct HModuleStatus {
    // MARK: - Properties

    private let areAllItemsOptional: Bool
    private let areAllItemsRequired: Bool
    private let hasOptionalItems: Bool
    private let hasRequiredItems: Bool

    // MARK: - Dependencies

    private let items: [HModuleItem]
    private let state: ModuleState?
    private let lockMessage: String?
    private let countOfPrerequisite: Int

    // MARK: - Init

    init(
        items: [HModuleItem],
        state: ModuleState?,
        lockMessage: String?,
        countOfPrerequisite: Int
    ) {
        self.items = items
        self.state = state
        self.lockMessage = lockMessage
        self.countOfPrerequisite = countOfPrerequisite
        self.areAllItemsOptional = items.allSatisfy { $0.isOptional }
        self.areAllItemsRequired = items.allSatisfy { !$0.isOptional }
        self.hasOptionalItems = items.contains { $0.isOptional }
        self.hasRequiredItems = items.contains { !$0.isOptional }
    }

    var status: HorizonUI.ModuleContainer.Status {
        if items.allSatisfy({ $0.isOptional }) {
            return .optional
        } else {
            switch state ?? .started {
            case .locked:
                return .locked
            case .unlocked:
                return .notStarted
            case .started:
                return .inProgress
            case .completed:
                return .completed
            }
        }
    }

    var subHeader: String? {
        guard !areAllItemsOptional else {
            return nil
        }

        guard status != .locked else {
            return lockMessage
        }

        if areAllItemsRequired {
            return hintMessageForRequiredItems
        }

        if hasOptionalItems && hasRequiredItems {
            if countOfPrerequisite == 1 {
                return Message.chooseMessage.localized
            } else {
                return Message.defaultMessage.localized
            }
        }
        return nil
    }

    private var hintMessageForRequiredItems: String? {
        switch status {
        case .notStarted:
            return Message.defaultMessage.localized
        case .inProgress, .completed:
            return Message.inProgressMessage.localized
        default:
            return nil
        }
    }
}

fileprivate extension HModuleStatus {
    enum Message {
        case defaultMessage
        case inProgressMessage
        case chooseMessage

        var localized: String {
            switch self {
            case .defaultMessage:
                return String(localized: "Complete all of the required items.", bundle: .horizon)
            case .inProgressMessage:
                return String(localized: "Complete all of the items.", bundle: .horizon)
            case .chooseMessage:
                return String(localized: "Choose and complete one of the required items.", bundle: .horizon)
            }
        }
    }
}
