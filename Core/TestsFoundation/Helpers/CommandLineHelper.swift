//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class CommandLine {
    enum ConnectionState: String {
        case on
        case off
    }

    private static let host = "http://localhost"
    private static let port: UInt16 = 4567

    private static func networkServices() throws -> [String.SubSequence] {
        let rawResult = try exec("networksetup -listallnetworkservices")
        var result = rawResult.split(separator: "\n")
        result.removeFirst() // First line is this string: "An asterisk (*) denotes that a network service is disabled."
        var services: [String.SubSequence] = []
        for service in result {
            var s = service
            if s.hasPrefix("*") {
                s.remove(at: s.startIndex)
            }
            services.append(s)
        }
        return services
    }

    static func isOffline() throws -> Bool {
        for service in try networkServices() {
            let output = try exec("networksetup -getnetworkserviceenabled '\(service)'")
            guard output == "Disabled" else { return false }
        }
        return true
    }

    static func isOnline() throws -> Bool {
        for service in try networkServices() {
            let output = try exec("networksetup -getnetworkserviceenabled '\(service)'")
            guard output == "Enabled" else { return false }
        }
        return true
    }

    static func setConnection(state: ConnectionState) throws {
        for service in try networkServices() {
            try exec("networksetup -setnetworkserviceenabled '\(service)' \(state) || true")
        }
    }

    @discardableResult
    private static func exec(_ command: String) throws -> String {
        let urlString = "\(host):\(port)/terminal?async=false"
        guard let url = URL(string: urlString) else { return "" }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["command": command], options: [])

        var output: String?
        var errorResult: Error?

        // Wait for the command to complete
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            defer { semaphore.signal() }

            if let error {
                errorResult = error
                return
            }

            if let urlResponse,
               let httpResponse = urlResponse as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                errorResult = NSError.instructureError("Error while executing terminal service command: HTTP \(httpResponse.statusCode)")
                return
            }

            if let data, let string = String(data: data, encoding: .utf8) {
                output = string
            }
        }
        task.resume()
        semaphore.wait()

        if let output {
            return output
        } else {
            throw errorResult ?? NSError.instructureError("Error while executing terminal service command.")
        }
    }
}
