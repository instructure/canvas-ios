//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Swifter

public protocol LoggingHttpServerDelegate: AnyObject {
    func didHandle(request: HttpRequest)
}

public class LoggingHttpServer: HttpServer {
    class MockWriter: HttpResponseBodyWriter {
        var data = Data()

        func write(_ file: String.File) throws { fatalError("unimplemented")  }
        func write(_ data: [UInt8]) throws { self.data += Data(data) }
        func write(_ data: ArraySlice<UInt8>) throws { self.data += Data(data) }
        func write(_ data: NSData) throws { self.data += data }
        func write(_ data: Data) throws { self.data += data }
    }

    public var logResponses: Bool = false
    public weak var postHandleDelegate: LoggingHttpServerDelegate?

    public override func dispatch(_ request: HttpRequest) -> ([String: String], (HttpRequest) -> HttpResponse) {
        let (params, handler) = super.dispatch(request)
        return (params, { [weak self] request in
            let response = handler(request)
            self?.postHandleDelegate?.didHandle(request: request)
            var queryString = ""
            if !request.queryParams.isEmpty {
                queryString = " \(request.queryParams)"
            }
            let alert = response.statusCode < 400 ? "" : " ❌"
            var log = "\(request.method) \(request.path)\(queryString) \(response.statusCode)\(alert)"
            if self?.logResponses == true {
                if case HttpResponse.raw(_, _, _, let body) = response {
                    let writer = MockWriter()
                    try? body?(writer)
                    var bodyData = writer.data
                    if let obj = try? JSONSerialization.jsonObject(with: bodyData, options: .fragmentsAllowed),
                       let prettyData = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) {
                        bodyData = prettyData
                    }
                    if let bodyStr = String(data: bodyData, encoding: .utf8) {
                        log += "\n\(bodyStr)"
                    } else {
                        log += "\n\(bodyData)"
                    }
                }
            }
            DispatchQueue.main.async {
                print(log)
            }
            return response
        })
    }
}
