//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

#if DEBUG
import Foundation
import Core
import Combine

class AssignmentInteractorPreview: AssignmentInteractor {
    func getSubmissions(ignoreCache: Bool) -> AnyPublisher<[HSubmission], Error> {
        Just([HSubmission(id: "11", assignmentID: "submittedAt", attempt: 2)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var attachments = CurrentValueSubject<[File], Never>([])
    var didUploadFiles = PassthroughSubject<Result<Void, Error>, Never>()

    func cancelFile(_ file: File) { }

    func cancelAllFiles() { }

    func uploadFiles() { }

    func addFile(url: URL) { }

    func getAssignmentDetails(ignoreCache: Bool) -> AnyPublisher<HAssignment, Error> {
        Just(HAssignment.mock())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func submitTextEntry(with text: String, moduleID: String, moduleItemID: String) -> AnyPublisher<[CreateSubmission.Model], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

#endif
