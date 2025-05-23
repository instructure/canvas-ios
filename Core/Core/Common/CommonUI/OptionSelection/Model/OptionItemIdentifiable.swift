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

import Foundation

public protocol OptionItemIdentifiable {
    var optionItemId: String { get }

    func isMatch(for optionItem: OptionItem?) -> Bool
}

extension OptionItemIdentifiable {
    public func isMatch(for optionItem: OptionItem?) -> Bool {
        optionItemId == optionItem?.id
    }
}

// MARK: - Conformances

extension OptionItemIdentifiable where Self: Identifiable<String> {
    public var optionItemId: String { id }
}

extension OptionItemIdentifiable where Self: RawRepresentable<String> {
    public var optionItemId: String { rawValue }
}

// MARK: - Arrays

extension Array where Element: OptionItemIdentifiable {
    public func element(for optionItem: OptionItem?) -> Element? {
        first { $0.optionItemId == optionItem?.id }
    }
}

extension Array<OptionItem> {
    public func option(for item: (some OptionItemIdentifiable)?) -> OptionItem? {
        first { $0.id == item?.optionItemId }
    }
}
