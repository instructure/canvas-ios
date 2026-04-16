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

public extension InstUI.Semantic {
    final class ColorLoader: Sendable {
        private let lightURL: URL
        private let darkURL: URL

        public init() throws {
            guard
                let lightURL = Bundle.module.url(forResource: "rebrandLight", withExtension: "json"),
                let darkURL  = Bundle.module.url(forResource: "rebrandDark",  withExtension: "json")
            else {
                throw InstUI.TokenLoadError.missingTokenFile("Bundled theme JSON not found")
            }
            self.lightURL = lightURL
            self.darkURL = darkURL
        }

        public init(lightURL: URL, darkURL: URL) {
            self.lightURL = lightURL
            self.darkURL = darkURL
        }

        public func load() throws -> InstUI.Semantic.Colors {
            let lightData = try Data(contentsOf: lightURL)
            let darkData  = try Data(contentsOf: darkURL)
            let resolver  = InstUI.ColorResolver()
            let lightLeaves = try InstUI.TokenExtractor.extractLeaves(from: lightData, section: "color")
            let darkLeaves  = try InstUI.TokenExtractor.extractLeaves(from: darkData,  section: "color")
            func token(_ path: String) throws -> Color {
                guard let lv = lightLeaves[path], let dv = darkLeaves[path] else {
                    throw InstUI.TokenLoadError.missingTokenFile(path)
                }
                return try resolver.adaptive(light: lv, dark: dv)
            }
            return try Colors.build(token)
        }
    }
}
