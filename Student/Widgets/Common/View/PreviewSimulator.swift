//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation

/**
 Simulators are listed by widget size, ascending.
 */
enum PreviewSimulator: String, CaseIterable {
    case iPhoneSE2 = "iPhone SE (2nd generation)"
    case iPhone12 = "iPhone 12"
    case iPhone8Plus = "iPhone 8 Plus"
    case iPhone11 = "iPhone 11"
    case iPhone12ProMax = "iPhone 12 Pro Max"
}

#endif
