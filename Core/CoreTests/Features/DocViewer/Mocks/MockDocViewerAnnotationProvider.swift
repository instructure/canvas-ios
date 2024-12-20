//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import PSPDFKit

class MockDocViewerAnnotationProvider: DocViewerAnnotationProvider {
    let document: Document
    var mockGetRepliesToAnnotationMethodResult: [DocViewerCommentReplyAnnotation] = []

    init(isAnnotatingDisabledInApp: Bool, isAPIEnabledAnnotations: Bool) {
        let bundle = Bundle(for: DocViewerAnnotationProviderTests.self)
        self.document = Document(url: bundle.url(forResource: "instructure", withExtension: "pdf")!)
        let documentProvider = document.documentProviders[0]

        super.init(documentProvider: documentProvider,
                   fileAnnotationProvider: PDFFileAnnotationProvider(documentProvider: documentProvider),
                   metadata: .make(annotations: .make(enabled: isAPIEnabledAnnotations)),
                   apiAnnotations: [],
                   api: API(),
                   sessionID: "",
                   isAnnotationEditingDisabled: isAnnotatingDisabledInApp)
    }

    override func getReplies(to: Annotation) -> [DocViewerCommentReplyAnnotation] {
        mockGetRepliesToAnnotationMethodResult
    }
}
