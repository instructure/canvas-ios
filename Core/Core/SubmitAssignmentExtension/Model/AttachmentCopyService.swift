//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

/**
 This service copies files from the app where the user hit the share button to the canvas app's shared directory
 so files will be accessible even after the share extension terminates.
 */
public class AttachmentCopyService {
    public enum State {
        case loading
        case completed(Result<[URL], Error>)
    }

    public let state = CurrentValueSubject<State, Never>(.loading)
    private let extensionItems: [NSExtensionItem]
    private var attachments: [URL] = []
    private var error: Error?

    public init(extensionContext: NSExtensionContext?) {
        self.extensionItems = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        Analytics.shared.logEvent("share_started", parameters: ["fileCount": extensionItems.count])
    }

    public func startCopying() {
        load(items: extensionItems)
    }

    private func load(items: [NSExtensionItem]) {
        let loadGroup = DispatchGroup()

        for item in items {
            item.attachments?.forEach { attachment in
                loadGroup.enter()
                load(attachment: attachment) { [weak self] result in
                    switch result {
                    case .success(let data):
                        self?.attachments.append(data)
                    case .failure(let error):
                        self?.error = error
                    }
                    loadGroup.leave()
                }
            }
        }

        loadGroup.notify(queue: .main) {
            self.updateState()
        }
    }

    private func load(attachment: NSItemProvider, callback: @escaping (Result<URL, Error>) -> Void) {
        guard let uti = attachment.uti else {
            let error = NSError.instructureError(NSLocalizedString("Format not supported", comment: ""))
            callback(.failure(error))
            return
        }
        attachment.loadItem(forTypeIdentifier: uti.rawValue, options: nil) { data, error in
            guard let coding = data, error == nil else {
                Analytics.shared.logError("error_getting_encoded_attachment_data", description: error?.localizedDescription)
                callback(.failure(error ?? NSError.internalError()))
                return
            }
            guard let appGroup = Bundle.main.appGroupID(), let container = URL.Directories.sharedContainer(appGroup: appGroup) else {
                callback(.failure(NSError.internalError()))
                return
            }
            let directory = container
                .appendingPathComponent("share-submit")
                .appendingPathComponent(UUID.string)
            do {
                let newURL: URL
                if let image = coding as? UIImage {
                    Analytics.shared.logEvent("processing_file", parameters: ["type": "image"])
                    newURL = try image.write(to: directory, nameIt: "image")
                } else if let url = coding as? URL {
                    Analytics.shared.logEvent("processing_file", parameters: ["type": "url", "extension": "\(url.pathExtension)"])
                    newURL = directory.appendingPathComponent(url.lastPathComponent)
                    try url.move(to: newURL, copy: true)
                } else if let data = coding as? Data {
                    Analytics.shared.logEvent("processing_file", parameters: ["type": "data"])
                    newURL = directory.appendingPathComponent("file")
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                    try data.write(to: newURL)
                } else {
                    Analytics.shared.logEvent("processing_file", parameters: ["type": "unknown", "class": "\(type(of: coding))"])
                    throw NSError.instructureError(NSLocalizedString("Format not supported", comment: ""))
                }
                callback(.success(newURL))
            } catch {
                Analytics.shared.logError("error_getting_file_data", description: error.localizedDescription)
                callback(.failure(error))
            }
        }
    }

    private func updateState() {
        let result: Result<[URL], Error>

        if error == nil && !attachments.isEmpty {
            result = .success(attachments)
        } else if let error = error {
            result = .failure(error)
        } else {
            result = .failure(NSError.instructureError(NSLocalizedString("No supported files to submit", comment: "")))
        }

        state.send(.completed(result))
    }
}
