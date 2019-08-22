//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import CoreData
import Foundation
import UIKit

public protocol RichContentEditorViewProtocol: class {
    func loadHTML()
    func showError(_ error: Error)
    func insertImagePlaceholder(_ url: URL, placeholder: String)
    func insertVideoPlaceholder(_ url: URL)
    func updateUploadProgress(of files: [File])
}

public class RichContentEditorPresenter: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let batchID = UUID.string
    var env: AppEnvironment = .shared
    let context: Context
    let uploadContext: FileUploadContext
    weak var view: RichContentEditorViewProtocol?

    lazy var files = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.update()
    }

    lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: context)) {}

    public init(env: AppEnvironment = .shared, view: RichContentEditorViewProtocol?, context: Context, uploadTo: FileUploadContext) {
        self.env = env
        self.context = context
        self.uploadContext = uploadTo
        self.view = view
    }

    func viewIsReady() {
        featureFlags.refresh(force: false) { [weak self] _ in
            self?.view?.loadHTML()
        }
    }

    func update() {
        view?.updateUploadProgress(of: files.map { $0 })
        let completes = files.filter { $0.mediaEntryID != nil || $0.url != nil || $0.uploadError != nil }
        guard !completes.isEmpty else { return }
        let context = NSPersistentContainer.shared.viewContext
        context.performAndWait {
            context.delete(completes)
            try? context.save()
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            self.files.refresh() // Actualize lazy local store
            do {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    self.createFile(try image.write(), isRetry: false, then: self.uploadImage)
                } else if let url = info[.mediaURL] as? URL {
                    self.createFile(url, isRetry: false, then: self.uploadMedia)
                } else {
                    throw NSError.instructureError(NSLocalizedString("No image found from image picker", bundle: .core, comment: ""))
                }
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func retry(_ url: URL) {
        if ["png", "jpeg", "jpg"].contains(url.pathExtension) {
            createFile(url, isRetry: true, then: uploadImage)
        } else {
            createFile(url, isRetry: true, then: uploadMedia)
        }
    }

    func createFile(_ url: URL, isRetry: Bool, then: @escaping (URL, File, Bool) -> Void) {
        let context = UploadManager.shared.viewContext
        context.performAndWait {
            do {
                let url = try UploadManager.shared.uploadURL(url)
                let file: File = context.insert()
                file.batchID = self.batchID
                file.localFileURL = url
                file.size = url.lookupFileSize()
                if let session = env.currentSession {
                    file.setUser(session: session)
                }
                try context.save()
                then(url, file, isRetry)
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func updateFile(_ file: File, error: Error?, mediaID: String? = nil) {
        let context = UploadManager.shared.viewContext
        context.performAndWait { [weak self] in
            do {
                guard let file = try? context.existingObject(with: file.objectID) as? File else { return }
                file.uploadError = error?.localizedDescription ?? file.uploadError
                file.mediaEntryID = mediaID
                try context.save()
            } catch {
                self?.view?.showError(error)
            }
        }
    }

    func uploadImage(_ url: URL, file: File, isRetry: Bool) {
        do {
            if !isRetry {
                let base64 = try Data(contentsOf: url).base64EncodedString()
                view?.insertImagePlaceholder(url, placeholder: "data:image/png;base64,\(base64)")
            }
            UploadManager.shared.upload(file: file, to: uploadContext)
        } catch {
            updateFile(file, error: error)
        }
    }

    func uploadMedia(_ url: URL, file: File, isRetry: Bool) {
        if !isRetry { view?.insertVideoPlaceholder(url) }
        UploadMedia(type: .video, url: url, file: file, context: context).fetch(environment: env) { [weak self] mediaID, error in
            self?.updateFile(file, error: error, mediaID: mediaID)
        }
    }
}
