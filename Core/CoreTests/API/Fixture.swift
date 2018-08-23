//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
typealias Template = [String: Any?]

protocol Fixture {
    static var template: Template { get }
}

extension Fixture where Self: Decodable {
    static func make(_ template: Template = [:]) -> Self {
        var t = self.template
        for (key, _) in template {
            t[key] = template[key]
        }
        for (key, value) in t {
            if let date = value as? Date {
                t[key] = date.isoString()
            }
        }
        let data = try! JSONSerialization.data(withJSONObject: t, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(Self.self, from: data)
    }
}
