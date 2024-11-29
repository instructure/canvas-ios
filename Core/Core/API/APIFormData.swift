//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public enum APIFormDatum: Equatable {
    case string(String)
    case data(filename: String, type: String, data: Data)
    case file(filename: String, type: String, at: URL)

    public static func bool(_ value: Bool) -> APIFormDatum {
        .string(value ? "1" : "0")
    }
    public static func date(_ value: Date?) -> APIFormDatum {
        .string(value?.isoString() ?? "")
    }
}

public typealias APIFormData = [(key: String, value: APIFormDatum)]

extension APIFormData {

    /**
     Encodes the form data into a file.
     - returns: The URL of the file where form data was written to.
     */
    public func encode(using boundary: String) throws -> URL {
        let tempFileURL = URL.Directories.temporary.appendingPathComponent(UUID.string)
        guard FileManager.default.createFile(atPath: tempFileURL.path, contents: nil),
              var outputStream = OutputStream(toFileAtPath: tempFileURL.path, append: false)
        else {
            throw NSError.instructureError("Failed to create temp file.")
        }

        outputStream.open()
        defer { outputStream.close() }
        try encode(to: &outputStream, boundary: boundary)
        return tempFileURL
    }

    public func encode(using boundary: String) throws -> Data {
        var outputStream = OutputStream(toMemory: ())
        outputStream.open()
        defer { outputStream.close() }
        try encode(to: &outputStream, boundary: boundary)
        return outputStream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data ?? Data()
    }

    private func encode(to outputStream: inout OutputStream, boundary: String) throws {
        let delimiter = "--\(boundary)\r\n"

        for (key, value) in self {
            outputStream += delimiter
            outputStream += "Content-Disposition: form-data; name=\"\(key)\""
            switch value {
            case .string(let string):
                outputStream += "\r\n\r\n\(string)"
            case .data(let filename, let type, let contents):
                outputStream += "; filename=\"\(filename.escaped)\"\r\nContent-Type: \(type)\r\n\r\n"
                outputStream += contents
            case .file(let filename, let type, let url):
                outputStream += "; filename=\"\(filename.escaped)\"\r\nContent-Type: \(type)\r\n\r\n"

                if url.isFileURL {
                    guard let inputStream = InputStream(fileAtPath: url.path) else {
                        throw NSError.instructureError("Failed to open file for reading.")
                    }
                    inputStream.open()
                    defer { inputStream.close() }
                    try inputStream.copy(to: outputStream)
                } else {
                    outputStream += try Data(contentsOf: url)
                }
            }
            outputStream += "\r\n"
        }

        outputStream += "--\(boundary)--\r\n"
    }
}

private extension String {

    /// Replaces " with \"
    var escaped: String {
        replacingOccurrences(of: "\"", with: "\\\"")
    }
}
