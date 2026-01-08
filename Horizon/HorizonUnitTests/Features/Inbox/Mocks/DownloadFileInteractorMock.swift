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

@testable import Horizon
import Core
import Combine
import Foundation

final class DownloadFileInteractorMock: DownloadFileInteractor {

    // MARK: - Tracking
    var downloadFileIDCallCount = 0
    var downloadFileIDWithCourseCallCount = 0
    var downloadFileCallCount = 0
    var downloadRemoteURLCallCount = 0
    var lastDownloadedFileID: String?
    var lastDownloadedFileIDWithCourse: (fileID: String, courseID: String?)?
    var lastDownloadedFile: File?
    var lastDownloadedRemoteURL: (remoteURL: URL, fileName: String)?

    // MARK: - Response Configuration
    var downloadFileIDResult: Result<URL, Error> = .success(URL(fileURLWithPath: "/tmp/test.pdf"))
    var downloadFileIDWithCourseResult: Result<URL, Error> = .success(URL(fileURLWithPath: "/tmp/test.pdf"))
    var downloadFileResult: Result<URL, Error> = .success(URL(fileURLWithPath: "/tmp/test.pdf"))
    var downloadRemoteURLResult: Result<URL, Error> = .success(URL(fileURLWithPath: "/tmp/test.pdf"))

    // MARK: - Delay Configuration
    var downloadDelay: TimeInterval = 0

    // MARK: - Inputs
    func download(fileID: String) -> AnyPublisher<URL, Error> {
        downloadFileIDCallCount += 1
        lastDownloadedFileID = fileID
        return createPublisher(result: downloadFileIDResult)
    }

    func download(fileID: String, courseID: String?) -> AnyPublisher<URL, Error> {
        downloadFileIDWithCourseCallCount += 1
        lastDownloadedFileIDWithCourse = (fileID, courseID)
        return createPublisher(result: downloadFileIDWithCourseResult)
    }

    func download(file: File) -> AnyPublisher<URL, Error> {
        downloadFileCallCount += 1
        lastDownloadedFile = file
        return createPublisher(result: downloadFileResult)
    }

    func download(remoteURL: URL, fileName: String) -> AnyPublisher<URL, Error> {
        downloadRemoteURLCallCount += 1
        lastDownloadedRemoteURL = (remoteURL, fileName)
        return createPublisher(result: downloadRemoteURLResult)
    }

    // MARK: - Helper Methods
    private func createPublisher(result: Result<URL, Error>) -> AnyPublisher<URL, Error> {
        if downloadDelay > 0 {
            return Future<URL, Error> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + self.downloadDelay) {
                    promise(result)
                }
            }
            .eraseToAnyPublisher()
        } else {
            return result.publisher.eraseToAnyPublisher()
        }
    }

    func simulateSuccess(_ url: URL) {
        downloadFileResult = .success(url)
    }

    func simulateFailure(_ error: Error) {
        downloadFileResult = .failure(error)
    }
}
