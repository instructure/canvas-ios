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

import Foundation

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
    var uploader: FileUploader = UploadFile(bundleID: Bundle.main.bundleIdentifier ?? Bundle.studentBundleID, appGroup: Bundle.main.appGroupID())
    weak var view: RichContentEditorViewProtocol?

    lazy var files: Store<LocalUseCase<File>> = env.subscribe(scope: .where(#keyPath(File.batchID), equals: batchID, orderBy: #keyPath(File.createdAt))) { [weak self] in
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
        env.database.perform { context in
            try? context.delete(completes)
            try? context.save()
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        do {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                createFile(try image.write(), then: uploadImage)
            } else if let url = info[.mediaURL] as? URL {
                createFile(url, then: uploadMedia)
            }
        } catch {
            view?.showError(error)
        }
    }

    func createFile(_ url: URL, then: @escaping (URL, File) -> Void) {
        env.database.perform { context in
            do {
                let file: File = context.insert()
                file.batchID = self.batchID
                file.localFileURL = url
                file.size = url.lookupFileSize()
                try context.save()
                then(url, file)
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func updateFile(_ file: File, error: Error?, mediaID: String? = nil) {
        env.database.perform { context in
            file.uploadError = error?.localizedDescription ?? file.uploadError
            file.mediaEntryID = mediaID
            try? context.save()
        }
    }

    func uploadImage(_ url: URL, file: File) {
        do {
            let base64 = try Data(contentsOf: url).base64EncodedString()
            view?.insertImagePlaceholder(url, placeholder: "data:image/png;base64,\(base64)")
            uploader.upload(file, context: uploadContext) { [weak self] error in
                self?.updateFile(file, error: error)
            }
        } catch {
            updateFile(file, error: error)
        }
    }

    func uploadMedia(_ url: URL, file: File) {
        view?.insertVideoPlaceholder(url)
        UploadMedia(type: .video, url: url, file: file).fetch(environment: env) { [weak self] mediaID, error in
            self?.updateFile(file, error: error, mediaID: mediaID)
        }
    }
}
