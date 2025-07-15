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

import Combine
import Core
import Foundation

class HCourseDocumentGoal: HGoal {

    private let cedar: DomainService
    private var courseID: String? {
        environment.courseID.value
    }
    private let downloadFileInteractor: DownloadFileInteractor
    private var fileID: String? {
        environment.fileID.value
    }

    private let environment: AssistDataEnvironment

    init(
        environment: AssistDataEnvironment,
        downloadFileInteractor: DownloadFileInteractor,
        cedar: DomainService = DomainService(.cedar)
    ) {
        self.environment = environment
        self.downloadFileInteractor = downloadFileInteractor
        self.cedar = cedar
    }

    override
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let response = response, response.isNotEmpty else {
            return initialPrompt()
        }
        return fetch()
            .flatMap { [weak self] (documentInput: CedarAnswerPromptMutation.DocumentInput?) -> AnyPublisher<AssistChatMessage?, any Error> in
                guard let self = self, let documentInput = documentInput else {
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.cedarAnswerPrompt(
                    prompt: response,
                    document: documentInput
                ).map {
                    .init(botResponse: $0 ?? "Sorry, I don't have an answer right now")
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    override
    func isRequested() -> Bool { courseID != nil && fileID != nil }

    // MARK: - Private Methods
    private func cedarAnswerPrompt(
        prompt: String,
        document: CedarAnswerPromptMutation.DocumentInput? = nil
    ) -> AnyPublisher<String?, Error> {
        cedar.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: document
                    )
                )
                .map { (response: CedarAnswerPromptMutationResponse?) in
                    response?.data.answerPrompt
                }
            }
            .eraseToAnyPublisher()
    }

    /// If necessary, downloads the file and returns the page context.
    /// If we can't determine the format, we return an empty page context
    private func fetch() -> AnyPublisher<CedarAnswerPromptMutation.DocumentInput?, Error> {
        guard let courseID = courseID, let fileID = fileID else {
            return Just<CedarAnswerPromptMutation.DocumentInput?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return ReactiveStore(useCase: GetFile(context: .course(courseID), fileID: fileID))
            .getEntities()
            .map { files in files.first }
            .flatMap { [weak self] (file: File?) in
                guard let self = self,
                      let file = file,
                      let format = AssistChatDocumentType.from(mimeType: file.contentType) else {
                    return Just<CedarAnswerPromptMutation.DocumentInput?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return self.downloadFileInteractor
                    .download(fileID: fileID)
                    .map { try? Data(contentsOf: $0) }
                    .map { $0?.base64EncodedString() }
                    .compactMap { (base64String: String?) in
                        guard let base64String = base64String else {
                            return nil
                        }
                        return CedarAnswerPromptMutation.DocumentInput(
                            format: format,
                            base64Source: base64String
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    private func initialPrompt() -> AnyPublisher<AssistChatMessage?, any Error> {
        Just(.init(botResponse: "Can I answer any questions about this document for you?"))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}

extension CedarAnswerPromptMutation.DocumentInput {
    /// A document block can be included  in the CedarAnswerPromptMutation to provide additional context for the model to generate a response.
    /// This is used when the user is viewing a document and wants to generate a response based on the document.
    static func build(from documentFormat: AssistChatDocumentType, base64Source: String) -> CedarAnswerPromptMutation.DocumentInput {
        CedarAnswerPromptMutation.DocumentInput(
            format: documentFormat,
            base64Source: base64Source
        )
    }
}
