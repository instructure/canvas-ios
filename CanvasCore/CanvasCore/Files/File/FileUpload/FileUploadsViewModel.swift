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
import ReactiveCocoa


import CoreData


enum DismissButtonType {
    case done
    case cancel
}

protocol FileUploadsViewModelInputs {
    // Call to configure with session and batch.
    // The batch must already be saved in the context.
    func configureWith(session: Session, batch: FileUploadBatch)

    func add(uploadable: Uploadable)
    func viewDidLoad()
    func tappedAddFile()
    func tappedDone()
    func tappedCancel()
}

protocol FileUploadsViewModelOutputs {
    var showDocumentMenu: Signal<[String], NoError> { get }
    var fileUploads: Signal<FetchedCollection<FileUpload>, NoError> { get }
    var dismissButtonType: Signal<DismissButtonType, NoError> { get }
    var files: Signal<[File], NoError> { get }
    var cancelled: Signal<Void, NoError> { get }
}

protocol FileUploadsViewModelType {
    var inputs: FileUploadsViewModelInputs { get }
    var outputs: FileUploadsViewModelOutputs { get }
}

final class FileUploadsViewModel: FileUploadsViewModelType, FileUploadsViewModelInputs, FileUploadsViewModelOutputs {
    init() {
        let session = sessionBatch.signal.skipNil().map { session, _ in session }
        let batch = sessionBatch.signal.skipNil().map { _, batch in batch }
        let context = session.map { try! $0.filesManagedObjectContext() }
        let apiPath = sessionBatch.signal.skipNil().map { _, batch in batch.apiPath }

        let token = Lifetime.Token()
        self.lifetimeToken = token

        self.showDocumentMenu = batch.map { $0.fileTypes }
            .sample(on: self.tappedAddFileProperty.signal)

        self.fileUploads = Signal.combineLatest(session, batch)
            .sample(on: viewDidLoadProperty.signal)
            .map { session, batch in
            return try! FileUpload.fetchCollection(session, batch: batch)
        }

        let contextDidSave = session
            .flatMap(.latest) { session -> Signal<Notification, NoError> in
                let context = try! session.filesManagedObjectContext()
                return NotificationCenter
                    .default
                    .reactive
                    .notifications(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
                    .take(during: Lifetime(token))
            }

        self.cancelled = batch
            .sample(with: contextDidSave)
            .filter { $1.deletedObjects.contains($0) }
            .ignoreValues()

        let inProgressCount = Signal.combineLatest(session, batch)
            .sample(on: Signal.merge(self.viewDidLoadProperty.signal, contextDidSave.ignoreValues()))
            .map { session, batch -> Int in
                let context = try! session.filesManagedObjectContext()
                let request: NSFetchRequest<FileUpload> = context.fetch(FileUpload.inProgressPredicate(batch: batch))
                return (try? context.count(for: request)) ?? 0
            }

        let completedCount = Signal.combineLatest(session, batch)
            .sample(on: Signal.merge(self.viewDidLoadProperty.signal, contextDidSave.ignoreValues()))
            .map { session, batch -> Int in
                let context = try! session.filesManagedObjectContext()
                let request: NSFetchRequest<FileUpload> = context.fetch(FileUpload.completedPredicate(batch: batch))
                return (try? context.count(for: request)) ?? 0
            }

        self.dismissButtonType = Signal.combineLatest(inProgressCount, completedCount)
            .map { inProgress, completed in
                if inProgress == 0 && completed > 0 {
                    return .done
                }
                return .cancel
            }
            .skipRepeats()

        let uploadAdded = Signal.combineLatest(session, batch, apiPath)
            .sample(with: addUploadableProperty.signal.skipNil())
            .map { sessionBatchApiPath, uploadable -> FileUpload in
                let session = sessionBatchApiPath.0
                let batch = sessionBatchApiPath.1
                let apiPath = sessionBatchApiPath.2
                let context = try! session.filesManagedObjectContext()

                var upload: FileUpload!
                context.performAndWait {
                    upload = FileUpload(inContext: context, uploadable: uploadable, path: apiPath, batch: batch)
                    _ = context.saveOrRollback()
                }
                return upload
            }

        self.files = batch
            .sample(on: contextDidSave.ignoreValues())
            .map { batch in
                return batch.fileUploads.map { $0.file }.compactMap { $0 }
            }
            .sample(on: tappedDoneProperty.signal)

        Signal.combineLatest(session, uploadAdded)
            .observeValues { session, upload in
                let context = try! session.filesManagedObjectContext()
                upload.begin(inSession: session, inContext: context)
            }

        Signal.combineLatest(context, batch)
            .sample(on: tappedCancelProperty.signal)
            .observeValues { context, batch in
                context.performChanges {
                    batch.delete(inContext: context)
                }
            }
    }

    fileprivate let sessionBatch = MutableProperty<(Session, FileUploadBatch)?>(nil)
    func configureWith(session: Session, batch: FileUploadBatch) {
        self.sessionBatch.value = (session, batch)
    }

    fileprivate let tappedAddFileProperty = MutableProperty(())
    func tappedAddFile() {
        self.tappedAddFileProperty.value = ()
    }

    fileprivate let addUploadableProperty = MutableProperty<Uploadable?>(nil)
    func add(uploadable: Uploadable) {
        self.addUploadableProperty.value = uploadable
    }

    fileprivate let viewDidLoadProperty = MutableProperty(())
    func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }

    fileprivate let tappedDoneProperty = MutableProperty(())
    func tappedDone() {
        self.tappedDoneProperty.value = ()
    }

    fileprivate let tappedCancelProperty = MutableProperty(())
    func tappedCancel() {
        self.tappedCancelProperty.value = ()
    }

    let showDocumentMenu: Signal<[String], NoError>
    let fileUploads: Signal<FetchedCollection<FileUpload>, NoError>
    let files: Signal<[File], NoError>
    let dismissButtonType: Signal<DismissButtonType, NoError>
    let cancelled: Signal<Void, NoError>

    private let lifetimeToken: Lifetime.Token

    var inputs: FileUploadsViewModelInputs { return self }
    var outputs: FileUploadsViewModelOutputs { return self }
}
