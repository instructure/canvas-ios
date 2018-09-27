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

public typealias Template = [String: Any?]

public protocol Fixture {
    static var template: Template { get }
}

public extension Fixture where Self: Decodable {
    static func make(_ template: Template = [:]) -> Self {
        let fixture = self.fixture(template)
        let data = try! JSONSerialization.data(withJSONObject: fixture, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(Self.self, from: data)
    }

    public static func fixture(_ template: Template = [:]) -> Template {
        var t = self.template
        for (key, _) in template {
            var value = template[key]
            if let date = value as? Date {
                value = date.isoString()
            }
            t[key] = value
        }
        return t
    }
}
