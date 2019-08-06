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
import MobileCoreServices
import Photos

public protocol DocumentMenuViewModelInputs {
    func configureWith(fileTypes: [String])
    func showDocumentMenuButtonTapped()
    func tappedDocumentOption(_ documentOption: DocumentOption)
    func pickedMedia(with info: [String: Any])
    func recorded(audioFile: URL)
    func pickedDocument(at url: URL)
    func tappedDocumentPicker(_ documentPicker: UIDocumentPickerViewController)
}

public protocol DocumentMenuViewModelOutputs {
    /// Emits array of document options and file types when the document menu should be presented.
    var showDocumentMenu: Signal<([DocumentOption], [String]), Never> { get }

    /// Emits source type and media types for image picker controller.
    var showImagePicker: Signal<(UIImagePickerController.SourceType, [String]), Never> { get }

    /// Emits complete button title when user is ready to record audio.
    var showAudioRecorder: Signal<String, Never> { get }

    /// Emits when the user selects a document picker from the document menu.
    var showDocumentPicker: Signal<UIDocumentPickerViewController, Never> { get }

    /// Emits the uploadables generated from input files.
    var uploadable: Signal<Uploadable, Never> { get }

    /// Emits any errors that occur.
    var errors: Signal<NSError, Never> { get }
}

public protocol DocumentMenuViewModelType {
    var inputs: DocumentMenuViewModelInputs { get }
    var outputs: DocumentMenuViewModelOutputs { get }
}

public class DocumentMenuViewModel: DocumentMenuViewModelType, DocumentMenuViewModelInputs, DocumentMenuViewModelOutputs {
    public init() {
        let fileTypes = fileTypesProperty.signal.skipNil()
        let tappedDocumentOption = self.tappedDocumentOptionProperty.signal.skipNil()

        self.showDocumentMenu = fileTypes
            .map { fileTypes in
                var options: [DocumentOption] = []
                let allowsAll = fileTypes.contains(kUTTypeItem as String)
                let allowsPhotos = allowsAll || fileTypes.any(isUTIPhoto)
                let allowsVideos = allowsAll || fileTypes.any(isUTIVideo)

                if allowsPhotos || allowsVideos {
                    options.append(.camera(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos))
                    options.append(.photoLibrary(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos))
                }

                if allowsAll || fileTypes.any(isUTIAudio) {
                    options.append(.recordAudio)
                }

                return options
            }
            .combineLatest(with: fileTypes)
            .sample(on: showDocumentMenuButtonTappedProperty.signal)

        self.showAudioRecorder = tappedDocumentOption
            .filter { option in
                if case .recordAudio = option {
                    return true
                }
                return false
            }
            .map { _ in
                return NSLocalizedString("Done",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Done recording button")
            }

        self.showImagePicker = tappedDocumentOption
            .map { option -> (UIImagePickerController.SourceType, [String])? in
                switch option {
                case let .camera(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos):
                    return (.camera, mediaTypes(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos))
                case let .photoLibrary(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos):
                    return (.photoLibrary, mediaTypes(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos))
                case .recordAudio:
                    return nil
                }
            }
            .skipNil()

        self.showDocumentPicker = self.tappedDocumentPickerProperty.signal.skipNil()

        let uploadableMediaEvent = self.pickedMediaProperty.signal
            .skipNil()
            .flatMap(.latest, uploadable(for:))
            .materialize()

        let uploadableAudioEvent = self.recordedAudioFileProperty.signal
            .skipNil()
            .flatMap(.latest, uploadableAudio(from:))
            .materialize()

        let uploadableDocumentEvent = self.pickedDocumentAtURLProperty.signal
            .skipNil()
            .flatMap(.latest, uploadableFile(from:))
            .materialize()

        self.uploadable = Signal.merge(uploadableMediaEvent.values(), uploadableAudioEvent.values(), uploadableDocumentEvent.values())

        self.errors = Signal.merge(uploadableMediaEvent.errors(), uploadableAudioEvent.errors(), uploadableDocumentEvent.errors())
    }

    private let fileTypesProperty = MutableProperty<[String]?>(nil)
    public func configureWith(fileTypes: [String]) {
        self.fileTypesProperty.value = fileTypes
    }

    private let tappedDocumentOptionProperty = MutableProperty<DocumentOption?>(nil)
    public func tappedDocumentOption(_ documentOption: DocumentOption) {
        self.tappedDocumentOptionProperty.value = documentOption
    }

    private let pickedMediaProperty = MutableProperty<[String: Any]?>(nil)
    public func pickedMedia(with info: [String : Any]) {
        pickedMediaProperty.value = info
    }

    private let recordedAudioFileProperty = MutableProperty<URL?>(nil)
    public func recorded(audioFile: URL) {
        recordedAudioFileProperty.value = audioFile
    }

    private let tappedDocumentPickerProperty = MutableProperty<UIDocumentPickerViewController?>(nil)
    public func tappedDocumentPicker(_ documentPicker: UIDocumentPickerViewController) {
        tappedDocumentPickerProperty.value = documentPicker
    }

    private let pickedDocumentAtURLProperty = MutableProperty<URL?>(nil)
    public func pickedDocument(at url: URL) {
        pickedDocumentAtURLProperty.value = url
    }

    private let showDocumentMenuButtonTappedProperty = MutableProperty(())
    public func showDocumentMenuButtonTapped() {
        showDocumentMenuButtonTappedProperty.value = ()
    }

    public let showDocumentMenu: Signal<([DocumentOption], [String]), Never>
    public let showAudioRecorder: Signal<String, Never>
    public let showImagePicker: Signal<(UIImagePickerController.SourceType, [String]), Never>
    public let showDocumentPicker: Signal<UIDocumentPickerViewController, Never>
    public let uploadable: Signal<Uploadable, Never>
    public let errors: Signal<NSError, Never>

    public var inputs: DocumentMenuViewModelInputs { return self }
    public var outputs: DocumentMenuViewModelOutputs { return self }
}

public func toUTI(_ ext: String) -> String {
    let cfUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
        .map { $0.takeRetainedValue() }
        .map { $0 as String }
    
    return cfUTI ?? ""
}

private func isUTIVideo(_ uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeMovie)
}

private func isUTIPhoto(_ uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeImage)
}

private func isUTIAudio(_ uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeAudio)
}

private func isUTIItem(_ uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeItem)
}

private func mediaTypes(allowsPhotos: Bool, allowsVideos: Bool) -> [String] {
    return (allowsPhotos ? [kUTTypeImage as String] : []) + (allowsVideos ? [kUTTypeMovie as String] : [])
}

private func uploadable(for info: [String: Any]) -> SignalProducer<Uploadable, NSError> {
    return SignalProducer { observer, _ in
        if let asset = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.phAsset)] as? PHAsset {
                Asset.fromCameraRoll(asset: asset) { result in
                    if let uploadable = result.value {
                        observer.send(value: uploadable)
                    } else {
                        observer.send(error: result.error ?? dataError)
                    }
                    observer.sendCompleted()
                }
        } else if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage, let data = image.pngData() {
            let uploadable = NewFileUpload(kind: .photo(image), data: data)
            observer.send(value: uploadable)
            observer.sendCompleted()
        } else if let videoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL, let data = try? Data(contentsOf: videoURL) {
            let uploadable = NewFileUpload(kind: .videoURL(videoURL), data: data)
            observer.send(value: uploadable)
            observer.sendCompleted()
        } else {
            observer.send(error: dataError)
        }
    }
}

private func uploadableAudio(from audioFile: URL) -> SignalProducer<Uploadable, NSError> {
    return attemptProducer {
        NewFileUpload(kind: .audioFile(audioFile), data: try Data(contentsOf: audioFile))
    }
    .mapError { _ in dataError }
}

private func uploadableFile(from url: URL) -> SignalProducer<Uploadable, NSError> {
    return attemptProducer {
        NewFileUpload(kind: .fileURL(url), data: try Data(contentsOf: url))
    }
    .mapError { _ in dataError }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
