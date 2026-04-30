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

import Foundation

extension InstUI {
    public typealias TokenKey = String
}

extension InstUI {
    enum TokenExtractor {
        /// Parses a W3C Design Tokens (DTCG) JSON file and returns all leaf token values
        /// under a given top-level section as a flat dictionary.
        ///
        /// **Input format** — each leaf node must have a `"value"` string field:
        /// ```json
        /// { "color": { "background": { "base": { "value": "{color.white}", "type": "color" } } } }
        /// ```
        ///
        /// **Output** — dotted paths mapped to raw value strings:
        /// ```
        /// ["background.base": "{color.white}"]
        /// ```
        /// The section key itself is stripped from the path; only the tree below it is included.
        /// Values are returned as-is — callers are responsible for resolving aliases
        /// (e.g. `{color.white}`) and converting to the appropriate Swift type.
        ///
        /// - Parameters:
        ///   - data: Raw JSON data of a DTCG token file.
        ///   - section: Top-level key to extract (e.g. `"color"`, `"size"`, `"spacing"`).
        /// - Throws: `InstUI.TokenLoadError.missingToken` if the section key is absent.
        static func extractLeaves(from data: Data, section: String) throws -> [TokenKey: String] {
            let root = try JSONSerialization.jsonObject(with: data)
            guard let rootDict = root as? [String: Any] else {
                throw InstUI.TokenLoadError.missingToken(section)
            }
            return try extractLeaves(from: rootDict, section: section)
        }

        /// Extracts leaf token values under a given top-level section from an already-parsed
        /// JSON dictionary. Use this overload when extracting multiple sections from the same
        /// file to avoid re-parsing the JSON for each section.
        ///
        /// - Parameters:
        ///   - rootDict: Pre-parsed top-level JSON object.
        ///   - section: Top-level key to extract (e.g. `"size"`, `"spacing"`).
        /// - Throws: `InstUI.TokenLoadError.missingToken` if the section key is absent.
        static func extractLeaves(from rootDict: [String: Any], section: String) throws -> [TokenKey: String] {
            guard let sectionDict = rootDict[section] as? [String: Any] else {
                throw InstUI.TokenLoadError.missingToken(section)
            }
            var result: [String: String] = [:]
            func walk(_ dict: [String: Any], _ prefix: String) {
                for (rawKey, val) in dict {
                    let key = rawKey.trimmingCharacters(in: .whitespaces)
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
}
