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

import SwiftUI

public protocol DateSectionViewModelProtocol: ObservableObject {

    var hasMultipleDueDates: Bool { get }
    var dueAt: Date? { get }
    var lockAt: Date? { get }
    var unlockAt: Date? { get }
    var forText: String { get }
    var isButton: Bool { get }

    func buttonTapped(router: Router, viewController: WeakViewController)
}

#if DEBUG
// MARK: - Preview Support
/**
Use only for SwiftUI previews.
*/
public class PreviewDateSectionViewModel: DateSectionViewModelProtocol {
    public var hasMultipleDueDates: Bool = false
    public var dueAt: Date?
    public var lockAt: Date?
    public var unlockAt: Date?
    public var forText: String
    public var isButton: Bool = false

    public init(dueAt: Date, lockAt: Date, unlockAt: Date, forText: String) {
        self.dueAt = dueAt
        self.lockAt = lockAt
        self.unlockAt = unlockAt
        self.forText = forText
    }

    public func buttonTapped(router: Router, viewController: WeakViewController) {}
}
// MARK: Preview Support -
#endif
