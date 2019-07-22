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
import CoreData

public protocol FileUploadViewModelInputs {
    func fileUpload(_ fileUpload: FileUpload, session: Session)
    func tappedDeleteUpload()
    func tappedErrorInfoButton()
    func tappedStatusButton()
}

public protocol FileUploadViewModelOutputs {
    var statusText: Signal<String, Never> { get }
    var errorInfoButtonIsHidden: Signal<Bool, Never> { get }
    var showError: Signal<String, Never> { get }
    var statusIcon: Signal<Icon, Never> { get }
    var graphic: Signal<Graphic, Never> { get }
    var imageData: Signal<Data, Never> { get }
    var progress: Signal<Double, Never> { get }
    var fileName: Signal<String, Never> { get }
    var statusTextColor: Signal<UIColor, Never> { get }
    var statusIconColor: Signal<UIColor?, Never> { get }
}

protocol FileUploadViewModelType {
    var inputs: FileUploadViewModelInputs { get }
    var outputs: FileUploadViewModelOutputs { get }
}

public final class FileUploadViewModel: FileUploadViewModelType, FileUploadViewModelInputs, FileUploadViewModelOutputs {
    public init() {
        let upload = self.fileUploadSession.signal.skipNil().map { fileUpload, _ in fileUpload }
        let status = upload.map { $0.status ?? .notStarted }

        self.statusText = status.map(statusText(for:)).skipRepeats(==)

        self.errorInfoButtonIsHidden = status.map { status in
            if case .failed = status {
                return false
            }
            return true
        }
        .skipRepeats()

        self.statusIcon = status.map(statusIcon(for:)).skipRepeats()

        self.statusTextColor = status.map(textColor(for:)).skipRepeats()

        self.statusIconColor = status.map(iconColor(for:))

        self.graphic = upload
            .filter { !$0.isImage }
            .map { $0.contentType }
            .map { $0.map(graphic(for:)) ?? Graphic(icon: .page, filled: true) }
            .skipRepeats()

        self.imageData = upload
            .filter { $0.isImage }
            .map { $0.data }
            .skipRepeats()

        self.progress = status
            .map { status -> Double in
                if case .inProgress(let progress) = status {
                    return max(5, progress)
                }
                return 0
            }
            .skipRepeats()

        self.fileName = upload.map { $0.name }.skipRepeats()

        self.showError = upload
            .map { $0.errorMessage }
            .sample(on: tappedErrorInfoButtonProperty.signal)
            .map { errorMessage in
                let defaultErrorMessage = NSLocalizedString("An error occurred, please try again.",
                                                            tableName: "Localizable",
                                                            bundle: .core, value: "",
                                                            comment: "Default error message displayed when a file fails to upload")
                return errorMessage ?? defaultErrorMessage
            }
            .skipRepeats()

        self.fileUploadSession.signal
            .skipNil()
            .sample(on: self.tappedDeleteUploadProperty.signal)
            .observeValues { upload, session in
                let context = try! session.filesManagedObjectContext()
                context.performChanges {
                    upload.abort()
                    upload.delete(inContext: context)
                }
            }

        let tappedCancel = self.statusIcon
            .sample(on: self.tappedStatusButtonProperty.signal)
            .filter { $0 == .cancel }
            .ignoreValues()

        let tappedRetry = self.statusIcon
            .sample(on: self.tappedStatusButtonProperty.signal)
            .filter { $0 == .refresh }
            .ignoreValues()

        self.fileUploadSession.signal.skipNil()
            .sample(on: tappedRetry)
            .observeValues { fileUpload, session in
                let context = try! session.filesManagedObjectContext()
                fileUpload.begin(inSession: session, inContext: context)
            }

        self.fileUploadSession.signal.skipNil()
            .sample(on: tappedCancel)
            .observeValues { fileUpload, session in
                let context = try! session.filesManagedObjectContext()
                context.performChanges {
                    fileUpload.abort()
                }
            }
    }

    private let fileUploadSession = MutableProperty<(FileUpload, Session)?>(nil)
    public func fileUpload(_ fileUpload: FileUpload, session: Session) {
        self.fileUploadSession.value = (fileUpload, session)
    }

    private let tappedDeleteUploadProperty = MutableProperty(())
    public func tappedDeleteUpload() {
        self.tappedDeleteUploadProperty.value = ()
    }

    private let tappedErrorInfoButtonProperty = MutableProperty(())
    public func tappedErrorInfoButton() {
        self.tappedErrorInfoButtonProperty.value = ()
    }

    private let tappedStatusButtonProperty = MutableProperty(())
    public func tappedStatusButton() {
        self.tappedStatusButtonProperty.value = ()
    }

    public let statusText: Signal<String, Never>
    public let errorInfoButtonIsHidden: Signal<Bool, Never>
    public let showError: Signal<String, Never>
    public let statusIcon: Signal<Icon, Never>
    public let graphic: Signal<Graphic, Never>
    public let imageData: Signal<Data, Never>
    public let progress: Signal<Double, Never>
    public let fileName: Signal<String, Never>
    public let statusTextColor: Signal<UIColor, Never>
    public let statusIconColor: Signal<UIColor?, Never>

    public var inputs: FileUploadViewModelInputs { return self }
    public var outputs: FileUploadViewModelOutputs { return self }
}

private func statusText(for status: Upload.Status) -> String {
    switch status {
    case .inProgress:
        return NSLocalizedString("uploading...",
                                 tableName: "Localizable",
                                 bundle: .core,
                                 value: "",
                                 comment: "File upload in progress")
    case .cancelled:
        return NSLocalizedString("Stopped",
                                 tableName: "Localizable",
                                 bundle: .core,
                                 value: "",
                                 comment: "File upload was stopped")
    case .failed:
        return NSLocalizedString("Failed",
                                 tableName: "Localizable",
                                 bundle: .core,
                                 value: "",
                                 comment: "File upload failed")
    case .completed:
        return NSLocalizedString("Complete",
                                 tableName: "Localizable",
                                 bundle: .core,
                                 value: "",
                                 comment: "File upload completed")
    case .notStarted:
        return ""
    }
}

private func statusIcon(for status: Upload.Status) -> Icon {
    switch status {
    case .failed, .cancelled:
        return .refresh
    case .inProgress, .notStarted:
        return .cancel
    case .completed:
        return .todo
    }
}

private func isIconTappable(_ icon: Icon) -> Bool {
    switch icon {
    case .cancel, .refresh:
        return true
    default: return false
    }
}

private func textColor(for status: Upload.Status) -> UIColor {
    switch status {
    case .inProgress, .notStarted:
        return .fileKit_uploadInProgress
    case .completed:
        return .fileKit_uploadCompleted
    case .cancelled, .failed:
        return .fileKit_uploadInterrupted
    }
}

private func iconColor(for status: Upload.Status) -> UIColor? {
    switch status {
    case .inProgress, .notStarted:
        return .fileKit_uploadInProgress
    case .completed:
        return .fileKit_uploadCompleted
    case .cancelled, .failed:
        return nil
    }
}

private func graphic(for contentType: String) -> Graphic {
    switch contentType {
    case "audio/mp4":
        return Graphic(icon: .audio)
    case "video/mpeg", "image/jpeg":
        return Graphic(icon: .camera)
    default:
        return Graphic(icon: .page, filled: true)
    }
}

extension FileUpload {
    @objc var isImage: Bool {
        return contentType == "image/jpeg"
    }
}
