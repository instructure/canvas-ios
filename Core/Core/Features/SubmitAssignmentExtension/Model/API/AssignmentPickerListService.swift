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
    typealias PageLoadingCompletion = () -> Void

    var result: AnyPublisher<APIResult, Never> { get }
    var pageInfo: AnyPublisher<APIPageInfo?, Never> { get }
    var courseID: String? { get set }

    func loadNextPage(completion: PageLoadingCompletion?)
}

public enum AssignmentPickerListServiceError: String, Error {
    case failedToGetAssignments
}

public class AssignmentPickerListService: AssignmentPickerListServiceProtocol {
    public private(set) lazy var result: AnyPublisher<APIResult, Never> = resultSubject.eraseToAnyPublisher()
    public private(set) lazy var pageInfo: AnyPublisher<APIPageInfo?, Never> = pageInfoSubject.eraseToAnyPublisher()

    public var courseID: String? {
        didSet { fetchAssignments() }
    }

    private var requestedCourseID: String?

    private let pageInfoSubject = CurrentValueSubject<APIPageInfo?, Never>(nil)
    private let resultSubject = CurrentValueSubject<APIResult, Never>(.success([]))

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

    public func loadNextPage(completion: (() -> Void)? = nil) {
        guard let courseID,
              let endCursor = pageInfoSubject.value?.endCursor
        else { return }

        let request = AssignmentPickerListRequest(courseID: courseID, cursor: endCursor)
        AppEnvironment.shared.api.makeRequest(request) { [weak self] response, _, error in
            self?.handleNextPageResponse(response, error: error, completedCourseID: courseID)
            completion?()
        }
    }

    private func handleResponse(_ response: AssignmentPickerListRequest.Response?, error: Error?, completedCourseID: String) {
        // If the finished request was for an older fetch we ignore its results
        if self.requestedCourseID != completedCourseID {
            return
        }

        let result: APIResult
        var pageInfo: APIPageInfo?

        if let response = response {
            let assignments = Self.filterAssignments(response.assignments)
            Analytics.shared.logEvent("assignments_loaded", parameters: ["count": assignments.count])
            result = .success(assignments)
            pageInfo = response.pageInfo
        } else {
            let errorMessage = error?.localizedDescription ?? String(localized: "Something went wrong", bundle: .core)
            Analytics.shared.logEvent("error_loading_assignments", parameters: ["error": errorMessage])
            RemoteLogger.shared.logError(name: "Assignment list load failed", reason: error?.localizedDescription)
            result = .failure(.failedToGetAssignments)
        }

        resultSubject.send(result)
        pageInfoSubject.send(pageInfo)
    }

    private func handleNextPageResponse(_ response: AssignmentPickerListRequest.Response?, error: Error?, completedCourseID: String) {
        // If the finished request was for an older fetch we ignore its results
        if self.requestedCourseID != completedCourseID {
            return
        }

        let currentResult: APIResult = resultSubject.value

        if let response = response {
            let newAssignments = Self.filterAssignments(response.assignments)
            Analytics.shared.logEvent("assignments_next_page_loaded", parameters: ["count": newAssignments.count])

            pageInfoSubject.send(response.pageInfo)
            resultSubject.send(.success(currentResult.value ?? [] + newAssignments))

        } else {
            let errorMessage = error?.localizedDescription ?? String(localized: "Something went wrong", bundle: .core)
            Analytics.shared.logEvent("error_loading_assignments_page", parameters: ["error": errorMessage])
            RemoteLogger.shared.logError(name: "Assignment list next page load failed", reason: error?.localizedDescription)
        }
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
