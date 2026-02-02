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

import SwiftUI

public enum LTIDomain: String, CaseIterable {
    case studio = "arc.instructure.com"
    case gauge = "gauge.instructure.com"
    case masteryConnect = "app.masteryconnect.com"
    case eportfolio = "portfolio.instructure.com"

    public init?(rawValue: String) {

        let ePortfolioRegionSpecificDomain: () -> LTIDomain? = {
            let lowercasedValue = rawValue.lowercased()
            let components = lowercasedValue.components(separatedBy: ".")

            if
                lowercasedValue.hasSuffix(Self.eportfolio.rawValue),
                components.count <= 4,
                components.first?.isNotEmpty == true {
                return .eportfolio
            }

            return nil
        }

        guard
            let domain = Self
                .allCases
                .first(where: { $0.rawValue == rawValue }) ?? ePortfolioRegionSpecificDomain()
        else { return nil }

        self = domain
    }

    public var icon: Image {
        switch self {
        case .studio: return .studioLine
        case .masteryConnect: return .masteryLTI
        case .eportfolio: return .eportfolioLine
        default: return Self.defaultIcon
        }
    }
    public static var defaultIcon: Image { .ltiLine }
}
