//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import CoreData
import Foundation
import UIKit

public protocol RichContentEditorViewProtocol: class {
    func showError(_ error: Error)
    func insertImagePlaceholder(_ url: URL, placeholder: String)
    func insertVideoPlaceholder(_ url: URL)
    func updateUploadProgress(of files: [File])
}

public class RichContentEditorPresenter: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let batchID = UUID.string
    var env: AppEnvironment = .shared
    let uploadContext: FileUploadContext
    weak var view: RichContentEditorViewProtocol?

    lazy var files = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.update()
    }

    public init(env: AppEnvironment = .shared, view: RichContentEditorViewProtocol?, uploadTo: FileUploadContext) {
        self.env = env
        self.uploadContext = uploadTo
        self.view = view
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
        let context = NSPersistentContainer.shared.viewContext
        context.performAndWait {
            do {
                let file: File = context.insert()
                file.batchID = self.batchID
                file.localFileURL = url
                file.size = url.lookupFileSize()
                file.user = env.currentSession.flatMap { File.User(id: $0.userID, baseURL: $0.baseURL, actAsUserID: $0.actAsUserID) }
                try context.save()
                then(url, file, isRetry)
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func updateFile(_ file: File, error: Error?, mediaID: String? = nil) {
        let context = NSPersistentContainer.shared.viewContext
        context.performAndWait { [weak self] in
            do {
                guard let file = context.object(with: file.objectID) as? File else { return }
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
        UploadMedia(type: .video, url: url, file: file).fetch(environment: env) { [weak self] mediaID, error in
            self?.updateFile(file, error: error, mediaID: mediaID)
        }
    }
}
