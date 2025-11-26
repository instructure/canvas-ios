//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import CoreData
import Combine
import UIKit

public class CreateSubmission: APIUseCase {
    let context: Context
    let assignmentID: String
    let userID: String
    let moduleID: String?
    let moduleItemID: String?

    public weak var retrialState: SubmissionRetrialState?
    public let request: CreateSubmissionRequest
    public typealias Model = Submission

    private let submissionType: SubmissionType
    private let mediaCommentType: MediaCommentType?
    private let mediaCommentSource: FilePickerSource?

    private var subscriptions = Set<AnyCancellable>()

    public init(
        context: Context,
        assignmentID: String,
        userID: String,
        submissionType: SubmissionType,
        textComment: String? = nil,
        isGroupComment: Bool? = nil,
        body: String? = nil,
        url: URL? = nil,
        fileIDs: [String]? = nil,
        mediaCommentID: String? = nil,
        mediaCommentType: MediaCommentType? = nil,
        mediaCommentSource: FilePickerSource? = nil,
        annotatableAttachmentID: String? = nil,
        moduleID: String? = nil,
        moduleItemID: String? = nil
    ) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.moduleID = moduleID
        self.moduleItemID = moduleItemID
        self.submissionType = submissionType
        self.mediaCommentType = mediaCommentType
        self.mediaCommentSource = mediaCommentSource

        let submission = CreateSubmissionRequest.Body.Submission(
            annotatable_attachment_id: annotatableAttachmentID,
            text_comment: textComment,
            group_comment: isGroupComment,
            submission_type: submissionType,
            body: body,
            url: url,
            file_ids: fileIDs,
            media_comment_id: mediaCommentID,
            media_comment_type: mediaCommentType
        )

        request = CreateSubmissionRequest(
            context: context,
            assignmentID: assignmentID,
            body: .init(submission: submission)
        )
    }

    public func settingRetrialState(_ state: SubmissionRetrialState?) -> Self {
        self.retrialState = state
        return self
    }

    public var cacheKey: String?

    public var scope: Scope { Scope(
        predicate: NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(Submission.assignmentID), assignmentID,
            #keyPath(Submission.userID), userID
        ),
        orderBy: #keyPath(Submission.attempt),
        ascending: false
    ) }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APISubmission?, URLResponse?, Error?) -> Void) {
        retrialState?.validateSync(for: request)

        environment.api.makeRequest(request) { [weak self, weak environment] response, urlResponse, error in
            guard let self = self else { return }

            if error == nil {
                NotificationCenter.default.post(moduleItem: .assignment(self.assignmentID), completedRequirement: .submit, courseID: self.context.id)
                if let moduleID = self.moduleID, let moduleItemID = self.moduleItemID {
                    NotificationCenter.default.post(
                        name: .moduleItemRequirementCompleted,
                        object: ModuleItemAttributes(
                            courseID: self.context.id,
                            moduleID: moduleID,
                            itemID: moduleItemID
                        )
                    )
                } else {
                    NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
                }
            }

            let isSuccessful = response != nil && error == nil

            // Analytics
            logAnalyticsEvent(
                phase: isSuccessful ? .succeeded : .failed,
                attempt: response?.attempt,
                env: environment
            )

            UIAccessibility
                .announceSubmission(isSuccessful: isSuccessful)
                .sink {
                    completionHandler(response, urlResponse, error)
                }
                .store(in: &subscriptions)
        }
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Submission.save(item, in: client)
        if item.late != true {
            NotificationCenter.default.post(name: .celebrateSubmission, object: nil, userInfo: [
                "assignmentID": assignmentID
            ])
        }
    }

    // MARK: Analytics Event

    private func logAnalyticsEvent(phase: Analytics.SubmissionEvent.Phase, attempt: Int?, env: AppEnvironment?) {
        guard let phasedType = analyticsPhasedEventType else { return }

        var params = mediaCommentType.flatMap({ mediaType in
            var params: [Analytics.SubmissionEvent.Param: Any] = [.media_type: mediaType.rawValue]
            if let source = mediaCommentSource {
                params[.media_source] = source.analyticsValue
            }
            return params
        })

        if let retrialState, phase == .succeeded || phase == .failed {
            params = params ?? [:]
            params?.merge(retrialState.paramsSync(), uniquingKeysWith: { $1 })
        }

        if let attempt {

            Analytics.shared.logSubmission(.phase(phase, phasedType, attempt), additionalParams: params)

        } else if let client = env?.database.viewContext {

            // This would mainly be executed on API failure case
            client.perform { [scope, client] in

                let latestSubmission: Submission? = client.fetch(scope: scope).first

                // Do your best to get the correct attempt number of last submission
                // If doesn't exist, fallback to `nil`
                let failureAttempt = latestSubmission.flatMap { $0.attempt + 1 }
                Analytics.shared.logSubmission(.phase(phase, phasedType, failureAttempt), additionalParams: params)
            }
        }

        retrialState?.reportSync(phase)
    }

    private var analyticsPhasedEventType: Analytics.SubmissionEvent.PhasedType? {
        if let phasedType = submissionType.analyticsValue { return phasedType }

        // This is currently passed for `studio` submissions
        if case .basic_lti_launch = submissionType { return .studio }

        return nil
    }
}

// MARK: - State Tracking

public class SubmissionRetrialState {
    private var inRetrialPhase: Bool = false
    private var request: CreateSubmissionRequest?
    private let synchronizer = DispatchQueue(label: "Submission state synchronized access")

    public init() {}

    func validate(for anotherRequest: CreateSubmissionRequest) {
        synchronizer.sync {
            validateSync(for: anotherRequest)
        }
    }

    func report(_ phase: Analytics.SubmissionEvent.Phase) {
        synchronizer.sync {
            reportSync(phase)
        }
    }

    func params() -> [Analytics.SubmissionEvent.Param: Any] {
        return synchronizer.sync {
            return paramsSync()
        }
    }

    fileprivate func validateSync(for anotherRequest: CreateSubmissionRequest) {
        guard let request else {
            self.request = anotherRequest
            self.inRetrialPhase = false
            return
        }

        if request != anotherRequest {
            self.request = anotherRequest
            self.inRetrialPhase = false
        }
    }

    fileprivate func reportSync(_ phase: Analytics.SubmissionEvent.Phase) {
        switch phase {
        case .succeeded:
            inRetrialPhase = false
        case .failed:
            inRetrialPhase = true
        case .selected, .presented:
            break
        }
    }

    fileprivate func paramsSync() -> [Analytics.SubmissionEvent.Param: Any] {
        return [.retry: inRetrialPhase ? 1 : 0]
    }
}
