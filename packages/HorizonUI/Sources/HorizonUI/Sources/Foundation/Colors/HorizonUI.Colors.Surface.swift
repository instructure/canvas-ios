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

public extension HorizonUI.Colors {
    struct Surface: Sendable, ColorCollection {
        public let attention = Color(hexString: "#2B7ABC")
        public let attentionSecondary = Color(hexString: "#0A5A9E")
        public let cardPrimary = Color(hexString: "#FFFFFF")
        public let cardSecondary = Color(hexString: "#FFFDFA")
        public let divider = Color(hexString: "#E8EAEC")
        public let error = Color(hexString: "#C71F23")
        public var institution: Color { Color(uiColor: Self.institutionWrapper.color) }
        public let inversePrimary = Color(hexString: "#273540")
        public let inverseSecondary = Color(hexString: "#0A1B2A")
        public let overlayGrey = Color(hexString: "#586874")
        public let overlayWhite = Color(hexString: "#FFFFFF")
        public let pagePrimary = Color(hexString: "#FBF5ED")
        public let pageSecondary = Color(hexString: "#FFFFFF")
        public let pageTertiary = Color(hexString: "#E8EAEC")
        public let warning = Color(hexString: "#CF4A00")
        public let success = Color(hexString: "#03893D")
        
        static let institutionWrapper = InstitutionWrapper()
        
        /// Helper data struct to set and get the primary brand color that is handled as Institution Color.
        final class InstitutionWrapper: @unchecked Sendable {
            // MARK: - Private Properties

            private var _color: UIColor = .black
            private let queue = DispatchQueue(label: "com.horizonUI.colors", attributes: .concurrent)

            public var color: UIColor {
                get {
                    return queue.sync { _color }
                } set {
                    queue.async(flags: .barrier) { self._color = newValue }
                }
            }
        }
    }
}
