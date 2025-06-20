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

import Core
import WidgetKit

enum GradesListStatusState {
    case failure
    case loggedOut

    var iconName: String {
        switch self {
        case .failure: "PandaUnsupported"
        case .loggedOut: "no-match-panda"
        }
    }

    var title: String {
        switch self {
        case .failure:
            String(localized: "Oops! Something Went Wrong")
        case .loggedOut:
            String(localized: "Let's Get You Logged In!")
        }
    }

    var subtitle: String {
        switch self {
        case .failure:
            String(localized: "We're having trouble showing your grades right now.  Please try again in a bit or head to the app.")
        case .loggedOut:
            String(localized: "To see your grades, please log in to your account in the app.  It'll just take a sec!")
        }
    }

    func imageHeight(for family: WidgetFamily) -> CGFloat {
        switch self {
        case .failure:
            family == .systemMedium ? 70 : 160
        case .loggedOut:
            family == .systemMedium ? 55 : 85
        }
    }
}
