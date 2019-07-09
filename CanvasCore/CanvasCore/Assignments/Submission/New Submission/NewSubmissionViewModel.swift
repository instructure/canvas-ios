//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import ReactiveSwift
import Result



import Marshal

public protocol NewSubmissionViewModelInputs {
    /// Call to configure with session and an assignment type.
    func configureWith(session: Session, assignment: AssignmentProtocol)

    /// Call when Turn In button is tapped.
    func tappedTurnIn()

    /// Call when submission type is selected.
    func submissionTypeButtonTapped(_ submissionType: SubmissionType)

    /// Call when ready to submit a NewSubmission.
    func submit(newSubmission: NewSubmission)

    /// Call when uploadable is selected.
    func selected(uploadable: Uploadable)
}

public protocol NewSubmissionViewModelOutputs {
    /// Emits when to select a submission type from an actionsheet.
    var showSubmissionTypesSheet: Signal<[SubmissionType], NoError> { get }

    /// Emits a list of file types when ready to start choosing files.
    var showDocumentMenu: Signal<[String], NoError> { get }

    /// Emits a session, course id, and an upload batch when ready to start choosing files.
    var showFileUploads: Signal<(Session, String, FileUploadBatch), NoError> { get }

    /// Emits when there was an error submitting.
    var showError: Signal<String, NoError> { get }

    /// Emits when ready to enter text entry.
    var showTextEntry: Signal<Void, NoError> { get }

    /// Emits when ready to select url submission.
    var showURLPicker: Signal<Void, NoError> { get }

    /// Emits when a submission is submitted.
    var submission: Signal<Submission, NoError> { get }
}

public protocol NewSubmissionViewModelType {
    var inputs: NewSubmissionViewModelInputs { get }
    var outputs: NewSubmissionViewModelOutputs { get }
}

public class NewSubmissionViewModel: NSObject, NewSubmissionViewModelType, NewSubmissionViewModelInputs, NewSubmissionViewModelOutputs {
    public override init() {
        let assignment = sessionAssignment.signal.skipNil().map { _, assignment in assignment }
        let session = sessionAssignment.signal.skipNil().map { session, _ in session }

        let submissionTypes = assignment
            .map { assignment -> [SubmissionType] in
                var submissionTypes: [SubmissionType] = []

                if assignment.submissionTypes.contains(.text) {
                    submissionTypes.append(.text)
                }

                if assignment.submissionTypes.contains(.url) {
                    submissionTypes.append(.url)
                }

                if !assignment.submissionTypes.intersection([.upload, .mediaRecording]).isEmpty {
                    submissionTypes.append(.fileUpload)
                }

                return submissionTypes
        }

        let selectedOnlySubmissionType = submissionTypes
            .filter { $0.count == 1 }
            .map { $0.first }
            .skipNil()
            .sample(on: self.tappedTurnInProperty.signal)

        self.showSubmissionTypesSheet = submissionTypes
            .filter { $0.count > 1 }
            .sample(on: self.tappedTurnInProperty.signal)

        let selectedSubmissionType = Signal.merge(selectedOnlySubmissionType, submissionTypeButtonTappedProperty.signal.skipNil())

        let fileTypes = assignment.map { Assignment.allowedSubmissionUTIs($0.submissionTypes, allowedExtensions: $0.allowedExtensions) }

        let apiPath = Signal.combineLatest(session, assignment)
            .flatMap(.latest, apiPathForFileSubmissions(in:for:))
            .materialize()
        let courseID = assignment.map { $0.courseID }
        let selectedUploadable = selectedUploadableProperty.signal.skipNil()
        let batch = Signal.combineLatest(session, fileTypes, apiPath.values())
            .sample(with: selectedUploadable)
            .map(blend)
            .map(insertBatch(in:fileTypes:apiPath:uploadable:))

        self.showFileUploads = Signal.combineLatest(session, courseID, batch)

        self.showTextEntry = selectedSubmissionType.filter { $0 == .text }.ignoreValues()

        self.showURLPicker = selectedSubmissionType.filter { $0 == .url }.ignoreValues()

        let selectedFileUploadSubmissionType = selectedSubmissionType.filter { $0 == .fileUpload }.ignoreValues()
        self.showDocumentMenu = fileTypes.sample(on: selectedFileUploadSubmissionType)

        let newSubmission = self.submitNewSubmissionProperty.signal.skipNil()
        let createSubmissionEvent = sessionAssignment.signal.skipNil()
            .sample(with: newSubmission)
            .map(blend)
            .flatMap(.latest) { session, assignment, newSubmission -> SignalProducer<Signal<Submission, NSError>.Event, NoError> in
                return attemptProducer {
                    try Submission.create(newSubmission, session: session, courseID: assignment.courseID, assignmentID: assignment.id, comment: nil)
                }
                .flatten(.latest)
                .materialize()
            }

        self.submission = createSubmissionEvent.values()

        self.showError = Signal.merge(apiPath.errors(), createSubmissionEvent.errors()).map { $0.localizedDescription }

        super.init()
    }

    fileprivate let sessionAssignment = MutableProperty<(Session, AssignmentProtocol)?>(nil)
    public func configureWith(session: Session, assignment: AssignmentProtocol) {
        sessionAssignment.value = (session, assignment)
    }

    private let tappedTurnInProperty = MutableProperty(())
    @objc public func tappedTurnIn() {
        tappedTurnInProperty.value = ()
    }

    private let submissionTypeButtonTappedProperty = MutableProperty<SubmissionType?>(nil)
    public func submissionTypeButtonTapped(_ submissionType: SubmissionType) {
        submissionTypeButtonTappedProperty.value = submissionType
    }

    private let submitNewSubmissionProperty = MutableProperty<NewSubmission?>(nil)
    public func submit(newSubmission: NewSubmission) {
        submitNewSubmissionProperty.value = newSubmission
    }

    private let selectedUploadableProperty = MutableProperty<Uploadable?>(nil)
    @objc public func selected(uploadable: Uploadable) {
        selectedUploadableProperty.value = uploadable
    }

    public let showSubmissionTypesSheet: Signal<[SubmissionType], NoError>
    public let showFileUploads: Signal<(Session, String, FileUploadBatch), NoError>
    public let showError: Signal<String, NoError>
    public let showTextEntry: Signal<Void, NoError>
    public let showURLPicker: Signal<Void, NoError>
    public let showDocumentMenu: Signal<[String], NoError>
    public let submission: Signal<Submission, NoError>

    public var inputs: NewSubmissionViewModelInputs { return self }
    public var outputs: NewSubmissionViewModelOutputs { return self }
}

private func apiPathForFileSubmissions(in session: Session, for assignment: AssignmentProtocol) -> SignalProducer<String, NSError> {
    let groupSetID = assignment.groupSetID

    let singleSubmissionPath = SignalProducer<String, NSError>(value: "/api/v1/courses/\(assignment.courseID)/assignments/\(assignment.id)/submissions/self/files")
    
    if groupSetID != nil {
        let groupsPath = "/api/v1/users/self/groups"
        let request = try! session.GET(groupsPath)
        
        let firstGroupID: ([JSONObject]) -> String? = { overrides in
            let groupID: (JSONObject) -> String? = {
                if let groupID = try? $0.stringID("id"), let groupCategoryID = try? $0.stringID("group_category_id"), groupCategoryID == groupSetID {
                    return groupID
                }
                return nil
            }
            return overrides
                .lazy
                .compactMap(groupID)
                .first
        }
        
        return session.paginatedJSONSignalProducer(request)
            .map(firstGroupID)
            .skipNil()
            .map { "/api/v1/groups/\($0)/files" }
            .concat(singleSubmissionPath)
            .take(first: 1)
    }

    return singleSubmissionPath
}

private func insertBatch(in session: Session, fileTypes: [String], apiPath: String, uploadable: Uploadable) -> FileUploadBatch {
    let context = try! session.filesManagedObjectContext()
    var batch: FileUploadBatch!
    context.performAndWait {
        batch = FileUploadBatch(session: session, fileTypes: fileTypes, apiPath: apiPath)
        _ = FileUpload(inContext: context, uploadable: uploadable, path: apiPath, batch: batch)
    }
    _ = context.saveOrRollback()
    return batch
}
