//
// Copyright (C) 2018-present Instructure, Inc.
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

class DocViewerUseCase: OperationSet {
    var annotations = [APIDocViewerAnnotation]()
    var localURL: URL?
    var metadata: APIDocViewerMetadata?
    var sessionID: String?
    var sessionURL: URL?

    init(api: API, previewURL: URL) {
        super.init()
        let getSession = GetDocViewerSession(url: previewURL, accessToken: api.accessToken ?? "")
        addSequence([ getSession, BlockOperation {
            guard let sessionURL = getSession.sessionURL else { return }
            self.loadMetadata(sessionID: sessionURL.lastPathComponent, sessionURL: sessionURL)
        }, ])
    }

    func loadMetadata(sessionID: String, sessionURL: URL) {
        self.sessionID = sessionID
        self.sessionURL = sessionURL
        let docViewerAPI = URLSessionAPI(accessToken: nil, baseURL: sessionURL)
        let getMeta = GetDocViewerMetadata(api: docViewerAPI)
        addSequence([ getMeta, BlockOperation {
            guard let metadata = getMeta.response else { return }
            self.metadata = metadata
            if metadata.annotations.enabled == true {
                self.loadAnnotations(docViewerAPI: docViewerAPI, sessionID: sessionID)
            }
            if let downloadURL = URL(string: metadata.urls.pdf_download.absoluteString, relativeTo: sessionURL) {
                self.loadDocument(docViewerAPI: docViewerAPI, downloadURL: downloadURL)
            }
        }, ])
    }

    func loadAnnotations(docViewerAPI: API, sessionID: String) {
        let getAnnotations = GetDocViewerAnnotations(api: docViewerAPI, sessionID: sessionID)
        addSequence([ getAnnotations, BlockOperation {
            self.annotations = getAnnotations.response?.data ?? []
        }, ])
    }

    func loadDocument(docViewerAPI: API, downloadURL: URL) {
        let getDocument = GetDocViewerDocument(api: docViewerAPI, downloadURL: downloadURL)
        addSequence([ getDocument, BlockOperation {
            self.localURL = getDocument.localURL
        }, ])
    }
}
