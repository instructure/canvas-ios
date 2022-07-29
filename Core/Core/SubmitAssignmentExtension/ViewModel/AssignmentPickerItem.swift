//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct AssignmentPickerItem: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let notAvailableReason: String?

    public init(apiItem: APIAssignmentPickerListItem, sharedFileExtensions: Set<String>) {
        let incompatibleExtensions = Array(sharedFileExtensions.subtracting(Set(apiItem.allowedExtensions))).sorted()
        var notAvailableReason: String?

        if !apiItem.allowedExtensions.isEmpty, !incompatibleExtensions.isEmpty {
            let availableExtensions = apiItem.allowedExtensions.sorted()
            let notCompatibleStringFormat = NSLocalizedString("incompatible_files_for_assignment", comment: "")
            let notCompatibleText = String.localizedStringWithFormat(notCompatibleStringFormat, incompatibleExtensions.count, incompatibleExtensions.joined(separator: ", "))

            let useExtensionsStringFormat = NSLocalizedString("use_file_extension", comment: "")
            let compatibleText = String.localizedStringWithFormat(useExtensionsStringFormat, availableExtensions.count, availableExtensions.joined(separator: ", "))
            notAvailableReason = "\(notCompatibleText)\n\(compatibleText)"
        }

        self.init(id: apiItem.id, name: apiItem.name, notAvailableReason: notAvailableReason)
    }

    public init(id: String, name: String, notAvailableReason: String? = nil) {
        self.id = id
        self.name = name
        self.notAvailableReason = notAvailableReason
    }
}
