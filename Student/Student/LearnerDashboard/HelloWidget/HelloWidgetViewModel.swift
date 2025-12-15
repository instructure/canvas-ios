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

@Observable
public final class HelloWidgetViewModel {
    var dayPeriod = DayPeriod.current

    init() {
    }

//    func greeting() -> LocalizedS   {
//        switch dayPeriod {
//        case .morning: "Good morning"
//        case .afternoon: "Good afternoon"
//        case .evening: "Good evening"
//        case .night: "Good night"
//        }
//    }
}

    public extension HelloWidgetViewModel {
        enum DayPeriod {
            case morning
            case afternoon
            case evening
            case night

            static var current: Self {
                switch Calendar.autoupdatingCurrent.component(.hour, from: .now) {
                case 0..<12: .morning
                case 12..<17: .afternoon
                case 17..<21: .evening
                default: .night
                }
            }
        }
    }
