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

import UIKit

enum HorizonTabBarType {
    case dashboard
    case learn
    case chatBot
    case skillspace
    case account

    var title: String {
        switch self {
        case .dashboard: String(localized: "Home", bundle: .horizon)
        case .learn: String(localized: "Learn", bundle: .horizon)
        case .chatBot: ""
        case .skillspace: String(localized: "Skillspace", bundle: .horizon)
        case .account: String(localized: "Account", bundle: .horizon)
        }
    }

    var index: Int {
        switch self {
        case .dashboard: 0
        case .learn: 1
        case .chatBot: 2
        case .skillspace: 3
        case .account: 4
        }
    }

    var image: UIImage? {
        switch self {
        case .dashboard: getHorizonImage(name: "home")
        case .learn: getHorizonImage(name: "book_2")
        case .chatBot: UIImage(resource: .chatBot)
        case .skillspace: getHorizonImage(name: "hub")
        case .account: getHorizonImage(name: "account_circle")
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .dashboard: getHorizonImage(name: "home_filled")
        case .learn: getHorizonImage(name: "book_2_filled")
        case .chatBot: UIImage(resource: .chatBot)
        case .skillspace: getHorizonImage(name: "hub_filled")
        case .account: getHorizonImage(name: "account_circle_filled")
        }
    }

    private func getHorizonImage(name: String) -> UIImage? {
        UIImage(named: name, in: Bundle.horizonUI, with: nil)
    }
}
