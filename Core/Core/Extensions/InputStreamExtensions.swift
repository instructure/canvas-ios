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

extension InputStream {

    /**
     Reads this stream until it is exhausted and writes its contents to the given `FileHandle`. The `FileHandle` must be created for writing.
     - parameters:
        - fileHandle: The file handle where the stream's content will be written. It must be created for writing and be opened.
        - bufferSize: The size of the buffer used during copiyng. The buffer is filled from this `InputStream` then written to the `FileHandle` until the stream has any content available. The default size of the buffer is 1 MB.
     */
    public func copy(to fileHandle: FileHandle, bufferSize: Int = 1_048_576) throws {
        var readResult: Int = 0
        var buffer: [UInt8] = Array(repeating: 0, count: bufferSize)
        let dataAvailable = { readResult > 0 }

        repeat {
            readResult = read(&buffer, maxLength: bufferSize)

            if dataAvailable() {
                let readDataSize = readResult
                let bufferContent = Data(bytes: buffer, count: readDataSize)
                try fileHandle.write(contentsOf: bufferContent)
            }
        } while dataAvailable()

        let errorOccurred = readResult < 0

        if errorOccurred {
            throw streamError ?? NSError.instructureError("Error while copying contents of InputStream to FileHandle.")
        }
    }
}
