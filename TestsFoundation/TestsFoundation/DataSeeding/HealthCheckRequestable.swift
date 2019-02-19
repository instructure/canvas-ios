//
// Copyright (C) 2018-present Instructure, Inc.
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
import Core

public struct APIHealthCheck: Codable, Equatable {
    public enum Status: String, Codable {
        case healthy = "canvas ok"
    }

    public let status: Status
    public var healthy: Bool {
        return status == .healthy
    }
}

public struct GetHealthCheckRequest: APIRequestable {
    public typealias Response = APIHealthCheck

    public let path = "/health_check"
    public let headers: [String : String?] = [
        HttpHeader.accept: "application/json"
    ]
}
