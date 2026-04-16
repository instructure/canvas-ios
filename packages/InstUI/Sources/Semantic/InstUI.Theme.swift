//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

extension InstUI {
    public struct Theme: Sendable {
        public let colors: InstUI.Semantic.Colors

        public static let `default`: InstUI.Theme = {
            // swiftlint:disable:next force_try
            try! InstUI.Theme()
        }()

        public init() throws {
            guard let lightURL = Bundle.module.url(forResource: "rebrandLight", withExtension: "json"),
                  let darkURL  = Bundle.module.url(forResource: "rebrandDark", withExtension: "json")
            else {
                throw InstUIColorLoadError.missingTokenFile("Bundled theme JSON not found")
            }
            try self.init(lightURL: lightURL, darkURL: darkURL)
        }

        public init(lightURL: URL, darkURL: URL) throws {
            let lightData = try Data(contentsOf: lightURL)
            let darkData  = try Data(contentsOf: darkURL)
            let resolver  = InstUIColorResolver()
            self.colors = try InstUI.Semantic.Colors.load(
                lightData: lightData,
                darkData: darkData,
                resolver: resolver
            )
        }
    }
}

public extension EnvironmentValues {
    @Entry var instUITheme: InstUI.Theme = .default
}
