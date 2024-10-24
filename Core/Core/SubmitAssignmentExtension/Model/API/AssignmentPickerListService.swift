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

import Combine

public protocol AssignmentPickerListServiceProtocol: AnyObject {
    typealias APIResult = Result<[APIAssignmentPickerListItem], AssignmentPickerListServiceError>
    var result: AnyPublisher<APIResult, Never> { get }
    var courseID: String? { get set }
}

public enum AssignmentPickerListServiceError: String, Error {
    case failedToGetAssignments
}

public class AssignmentPickerListService: AssignmentPickerListServiceProtocol {
    public private(set) lazy var result: AnyPublisher<APIResult, Never> = resultSubject.eraseToAnyPublisher()
    public var courseID: String? {
        didSet { fetchAssignments() }
    }

    private var requestedCourseID: String?
    private let resultSubject = PassthroughSubject<APIResult, Never>()

    public init() {
    }

    private func fetchAssignments() {
        guard let courseID = courseID else {
            return
        }

        requestedCourseID = courseID
        let request = AssignmentPickerListRequest(courseID: courseID)
        AppEnvironment.shared.api.makeRequest(request) { [weak self] response, _, error in
            self?.handleResponse(response, error: error, completedCourseID: courseID)
        }
    }

    private func handleResponse(_ response: AssignmentPickerListRequest.Response?, error: Error?, completedCourseID: String) {
        // If the finished request was for an older fetch we ignore its results
        if self.requestedCourseID != completedCourseID {
            return
        }

        let result: APIResult

        if let response = response {
            let assignments = Self.filterAssignments(response.assignments)
            Analytics.shared.logEvent("assignments_loaded", parameters: ["count": assignments.count])
            result = .success(assignments)
        } else {
            let errorMessage = error?.localizedDescription ?? String(localized: "Something went wrong", bundle: .core)
            Analytics.shared.logEvent("error_loading_assignments", parameters: ["error": errorMessage])
            Analytics.shared.logError(name: "Assignment list load failed", reason: error?.localizedDescription)
            result = .failure(.failedToGetAssignments)
        }

        resultSubject.send(result)
    }

    private static func filterAssignments(_ assignments: [AssignmentPickerListResponse.Assignment]) -> [APIAssignmentPickerListItem] {
        assignments.compactMap {
            guard $0.isLocked == false, $0.submissionTypes.contains(.online_upload) else { return nil }
            return APIAssignmentPickerListItem(
                id: $0._id,
                name: $0.name,
                allowedExtensions: $0.allowedExtensions ?? [],
                gradeAsGroup: $0.gradeAsGroup
            )
        }
    }
}
