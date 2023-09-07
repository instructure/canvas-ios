//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import mobile_offline_downloader_ios

public struct DownloaderClient {
    public static func setup() {
        let storageConfig = OfflineStorageConfig()
        OfflineStorageManager.shared.setConfig(config: storageConfig)

        let downloaderConfig = OfflineDownloaderConfig()
        downloaderConfig.errorsDescriptionHandler = { errorInfo, isCritical in
            if errorInfo == nil && isCritical == false {
                // successful downloading
                OfflineLogsMananger().logCompleted()
            } else {
                // was ended with error
                // Analytic
                OfflineLogsMananger().logError()
                // Bugfender
                if let errorInfo = errorInfo {
                    OfflineLogsMananger().logBugfenderError(errorInfo: errorInfo)
                }
            }
        }
        downloaderConfig.downloadTypes = [Page.self, ModuleItem.self, File.self]
        downloaderConfig.linksHandler = { urlString in
            if urlString.contains("/files/") && !urlString.contains("/download") && urlString.contains(AppEnvironment.shared.api.baseURL.absoluteString) {
                return urlString.replacingOccurrences(of: "?", with: "/download?")
                    .replacingOccurrences(of: "/preview", with: "")
            }
            return urlString
        }
        OfflineDownloadsManager.shared.setConfig(downloaderConfig)
        DispatchQueue.main.async {
            OfflineHTMLDynamicsLinksExtractor.processPool = CoreWebView.processPool
        }
    }

    public static func replaceHtml(for tag: String?) async -> String? {
        if tag?.lowercased() == "video" ||
            tag?.lowercased() == "audio" ||
            tag?.lowercased() == "iframe" ||
            tag?.lowercased() == "source",
            let image = UIImage(named: "PandaBlindfold", in: .core, with: nil) {
            let originWidth = image.size.width
            let imageData = image
                .pngData()?
                .base64EncodedString() ?? ""
            let result = """
                    <div style = "width:100%; border: 2px solid #e5146fff;" >
                        <center>
                            <div style="padding: 10px;">
                                <img width = "\(originWidth)" src="data:image/png;base64, \(imageData)">
                                <p> Content available online only </p>
                            </div>
                        </center>
                    </div>
                """
            return result
        }
        return nil
    }
}
