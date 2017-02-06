//
//  NewSubmissionViewModel.swift
//  Assignments
//
//  Created by Nathan Armstrong on 1/23/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import ReactiveSwift
import Result
import TooLegit
import SoLazy
import FileKit
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
}

public protocol NewSubmissionViewModelOutputs {
    /// Emits when to select a submission type from an actionsheet.
    var showSubmissionTypesSheet: Signal<[SubmissionType], NoError> { get }

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
            .flatMap(.latest, transform: apiPathForFileSubmissions(in:for:))
            .materialize()
        let courseID = assignment.map { $0.courseID }
        let batch = Signal.combineLatest(session, fileTypes, apiPath.values()).map(insertBatch(in:fileTypes:apiPath:))
        let tappedSubmitFileUpload = selectedSubmissionType.filter { $0 == .fileUpload }.ignoreValues()
        self.showFileUploads = Signal.combineLatest(session, courseID, batch)
            .sample(on: tappedSubmitFileUpload)

        self.showTextEntry = selectedSubmissionType.filter { $0 == .text }.ignoreValues()

        self.showURLPicker = selectedSubmissionType.filter { $0 == .url }.ignoreValues()

        let newSubmission = self.submitNewSubmissionProperty.signal.skipNil()
        let createSubmissionEvent = sessionAssignment.signal.skipNil()
            .sample(with: newSubmission)
            .flatMap(.latest) { sessionAssignment, newSubmission -> SignalProducer<Event<Submission, NSError>, NoError> in
                let session = sessionAssignment.0
                let assignment = sessionAssignment.1
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

    private let tappedTurnInProperty = MutableProperty()
    public func tappedTurnIn() {
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

    public let showSubmissionTypesSheet: Signal<[SubmissionType], NoError>
    public let showFileUploads: Signal<(Session, String, FileUploadBatch), NoError>
    public let showError: Signal<String, NoError>
    public let showTextEntry: Signal<Void, NoError>
    public let showURLPicker: Signal<Void, NoError>
    public let submission: Signal<Submission, NoError>

    public var inputs: NewSubmissionViewModelInputs { return self }
    public var outputs: NewSubmissionViewModelOutputs { return self }
}

private func apiPathForFileSubmissions(in session: Session, for assignment: AssignmentProtocol) -> SignalProducer<String, NSError> {
    let id = assignment.id
    let courseID = assignment.courseID
    let groupSetID = assignment.groupSetID

    let singleSubmissionPath = SignalProducer<String, NSError>(value: "/api/v1/courses/\(assignment.courseID)/assignments/\(assignment.id)/submissions/self/files")
    
    if groupSetID != nil {
        let overridesPath = "/api/v1/courses/\(courseID)/assignments/\(id)/overrides"
        let request = try! session.GET(overridesPath)
        
        let firstGroupID: ([JSONObject]) -> String? = { overrides in
            let groupID: (JSONObject) -> String? = {
                return try? $0.stringID("group_id")
            }
            return overrides
                .lazy
                .flatMap(groupID)
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

private func insertBatch(in session: Session, fileTypes: [String], apiPath: String) -> FileUploadBatch {
    let context = try! session.filesManagedObjectContext()
    var batch: FileUploadBatch!
    context.performAndWait {
        batch = FileUploadBatch(session: session, fileTypes: fileTypes, apiPath: apiPath)
    }
    context.saveOrRollback()
    return batch
}
