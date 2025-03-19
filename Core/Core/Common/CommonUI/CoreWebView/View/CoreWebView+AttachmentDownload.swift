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

import Foundation
import WebKit

public struct CoreWebAttachment {
    let url: URL
    let contentType: String?

    fileprivate init(url: URL, contentType: String?) {
        self.url = url
        self.contentType = contentType
    }
}

extension CoreWebView: WKDownloadDelegate {

    public var isDownloadingAttachment: Bool { downloadingAttachment != nil }

    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.hasAttachmentContentDispositionHeader
        else { return nil }

        let suggestedUrl = URL.Directories.temporary.appending(component: suggestedFilename)
        let attachment = CoreWebAttachment(
            url: suggestedUrl,
            contentType: httpResponse.value(forHTTPHeaderField: HttpHeader.contentType)
        )

        downloadingAttachment = attachment

        do {
            if FileManager.default.fileExists(atPath: suggestedUrl.path()) {
                try FileManager.default.removeItem(at: suggestedUrl)
            }

            linkDelegate?.coreWebView(self, didStartDownloadAttachment: attachment)

            return suggestedUrl
        } catch {

            return nil
        }
    }

    public func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        guard
            let attachment = downloadingAttachment,
            let fileURL = download.progress.fileURL,
            fileURL == attachment.url
        else { return }

        linkDelegate?.coreWebView(self, didFailAttachmentDownload: attachment, with: error)
        downloadingAttachment = nil
    }

    public func downloadDidFinish(_ download: WKDownload) {
        guard
            let attachment = downloadingAttachment,
            let fileURL = download.progress.fileURL,
            fileURL == attachment.url
        else { return }

        linkDelegate?.coreWebView(self, didFinishAttachmentDownload: attachment)
        downloadingAttachment = nil
    }
}
