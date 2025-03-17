//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@preconcurrency import WebKit
import SwiftUI
import UIKit

class AttachmentPrompt {
    private enum Action {
        case view(URL)
        case download(URL)
    }

    private var selectedAction: Action?
    private weak var progressVC: UIViewController?

    private func reset() {
        selectedAction = nil
        progressVC = nil
    }

    func shouldPrompt(for response: URLResponse) -> Bool {
        guard
            let headers = (response as? HTTPURLResponse)?.allHeaderFields,
            let contentDisposition = headers["Content-Disposition"] as? String,
            contentDisposition.hasPrefix("attachment")
        else { return false }

        // Exclude images
        if let contentType = headers["Content-Type"] as? String,
           contentType.hasPrefix("image/") {
            return false
        }

        return true
    }

    private func showProgress(for download: WKDownload) {
        let progressView = CoreHostingController(
            DownloadAlertView(onCancel: {
                download.cancel()
            })
        )

        progressView.view.backgroundColor = .clear
        progressView.modalTransitionStyle = .crossDissolve
        progressView.modalPresentationStyle = .overCurrentContext

        progressVC = progressView
        topController?.present(progressView, animated: true)
    }

    @MainActor
    func show(download: WKDownload, suggestedName: String, contentType: String?) async -> URL? {
        return await withCheckedContinuation { [weak self] continuation in
            guard let self else { return continuation.resume(returning: nil) }

            show(download: download, suggestedName: suggestedName, contentType: contentType) { url in
                continuation.resume(returning: url)
            }
        }
    }

    func show(download: WKDownload, suggestedName: String, contentType: String?, response: @escaping (URL?) -> Void) {
        let suggestedUrl = URL.Directories.temporary.appending(component: suggestedName)
        try? FileManager.default.removeItem(at: suggestedUrl)

        let alert = UIAlertController(title: "File Attachment", message: "\"\(suggestedName)\" is about to be downloaded for ?", preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(title: "Saving", style: .default, handler: { _ in
                response(suggestedUrl)
                self.selectedAction = .download(suggestedUrl)
                self.showProgress(for: download)
            })
        )

        if let contentType,
           viewableContentTypes.contains(where: { contentType.hasPrefix($0) }) {

            alert.addAction(
                UIAlertAction(title: "Viewing", style: .default, handler: { _ in
                    response(suggestedUrl)
                    self.selectedAction = .view(suggestedUrl)
                    self.showProgress(for: download)
                })
            )
        }

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                response(nil)
            })
        )

        topController?.present(alert, animated: true)
    }

    private var viewableContentTypes: [String] {
        return ["audio", "video", "image", "application/pdf"]
    }

    func downloadFailed(_ error: any Error) {
        progressVC?.dismiss(animated: true)
        reset()
    }

    func downloadFinished(in webView: WKWebView) {
        if let progressVC {
            progressVC.dismiss(animated: true) {
                self.takeAction(in: webView)
            }
        } else {
            takeAction(in: webView)
        }
    }

    private func takeAction(in webView: WKWebView) {
        progressVC?.dismiss(animated: false)

        guard let selectedAction else { return }

        switch selectedAction {
        case .view(let url):

            webView.loadFileURL(url, allowingReadAccessTo: url)

        case .download(let url):

            let activityVC = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )

            topController?.present(activityVC, animated: true)
        }

        reset()
    }

    private var topController: UIViewController? {
        return AppEnvironment.shared.topViewController
    }
}

struct DownloadAlertView: View {

    @Environment(\.viewController) var controller

    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color
                .backgroundDarkest
                .opacity(0.1)
                .ignoresSafeArea()
            VStack(alignment: .trailing) {
                HStack {
                    ProgressView().progressViewStyle(.circular)
                    Text("Downloading").font(.medium16)
                    Spacer().frame(minWidth: 40, maxWidth: 80)
                }
                Button("Cancel",
                       action: {
                        onCancel()
                        controller.value.dismiss(animated: true)
                    })
                    .font(.semibold14)
                    .tint(.red)
            }
            .padding()
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
        }
    }
}
