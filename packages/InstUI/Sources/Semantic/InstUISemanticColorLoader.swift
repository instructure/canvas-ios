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

extension InstUI.Semantic.Colors {

    static func load(
        lightData: Data,
        darkData: Data,
        resolver: InstUIColorResolver
    ) throws -> InstUI.Semantic.Colors {
        let lightLeaves = try extractLeaves(from: lightData, section: "color")
        let darkLeaves  = try extractLeaves(from: darkData,  section: "color")

        func token(_ path: String) throws -> Color {
            guard let lv = lightLeaves[path], let dv = darkLeaves[path] else {
                throw InstUIColorLoadError.missingTokenFile(path)
            }
            return try resolver.adaptive(light: lv, dark: dv)
        }

        return try build(token)
    }

    private static func extractLeaves(from data: Data, section: String) throws -> [String: String] {
        let root = try JSONSerialization.jsonObject(with: data)
        guard let rootDict = root as? [String: Any],
              let sectionDict = rootDict[section] as? [String: Any] else {
            throw InstUIColorLoadError.missingTokenFile(section)
        }
        var result: [String: String] = [:]
        func walk(_ dict: [String: Any], _ prefix: String) {
            for (key, val) in dict {
                let path = prefix.isEmpty ? key : "\(prefix).\(key)"
                if let leaf = val as? [String: Any], let value = leaf["value"] as? String {
                    result[path] = value
                } else if let nested = val as? [String: Any] {
                    walk(nested, path)
                }
            }
        }
        walk(sectionDict, "")
        return result
    }
}
