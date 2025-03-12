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

import UIKit

enum ModulePublishAction: Equatable {
    enum Subject: Equatable {
        case modulesAndItems
        case onlyModules
    }

    case publish(Subject?)
    case unpublish(Subject?)

    var isPublish: Bool {
        switch self {
        case .publish: true
        case .unpublish: false
        }
    }

    var subject: Subject? {
        switch self {
        case .publish(let actionSubject): actionSubject
        case .unpublish(let actionSubject): actionSubject
        }
    }

    var updatesModuleItems: Bool {
        guard let subject else { return true }

        switch subject {
        case .modulesAndItems: return true
        case .onlyModules: return false
        }
    }

    static let publish = Self.publish(nil)
    static let unpublish = Self.unpublish(nil)
}

struct ModulePublishItem {
    let title: String
    let confirmMessage: String
    var accessibilityIdentifier: String?
    let action: ModulePublishAction

    var icon: UIImage {
        switch action {
        case .publish: return .completeLine
        case .unpublish: return .noLine
        }
    }
}
