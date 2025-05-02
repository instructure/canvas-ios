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
import CoreData
import Core

class UpdateNotebookNoteUseCase: UseCase {
    var cacheKey: String?

    typealias Model = CDNotebookNote

    // MARK: Dependencies
    let redwood: DomainService

    // MARK: Overridden Properties
    let request: RedwoodUpdateNoteMutation

    public var scope: Scope {
        Scope(predicate: NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.id), request.variables.id), order: [])
    }

    // MARK: Private Properties
    private var subscriptions = Set<AnyCancellable>()

    // MARK: Init
    init(updateNoteMutation: RedwoodUpdateNoteMutation, redwood: DomainService = DomainService(.redwood)) {
        self.request = updateNoteMutation
        self.redwood = redwood
    }

    // MARK: Overridden Methods
    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        redwood
            .api()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] api in
                    guard let self = self else { return }
                    api.makeRequest(self.request, callback: completionHandler)
                }
            )
            .store(in: &subscriptions)
    }

    func write(response: RedwoodUpdateNoteMutationResponse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let redwoodNote = response?.data.updateNote {
            CDNotebookNote.save(redwoodNote, in: client)
        }
    }
}

extension CDNotebookNote {
    @discardableResult
    public static func save(
        _ item: RedwoodNote,
        notebookNote: CDNotebookNote? = nil,
        in context: NSManagedObjectContext
    ) -> CDNotebookNote {
        let model: CDNotebookNote = notebookNote ?? context.first(where: #keyPath(CDNotebookNote.id), equals: item.id) ?? context.insert()

        model.content = item.userText
        model.courseID = item.courseId
        model.date = item.createdAt
        model.end = Int16(item.highlightData?.textPosition.end ?? -1)
        model.endContainer = item.highlightData?.range.endContainer
        model.endOffset = Int16(item.highlightData?.range.endOffset ?? -1)
        model.id = item.id
        model.labels = item.reaction?.serializeLabels
        model.objectType = item.objectType
        model.pageID = item.objectId
        model.selectedText = item.highlightData?.selectedText
        model.start = Int16(item.highlightData?.textPosition.start ?? -1)
        model.startContainer = item.highlightData?.range.startContainer
        model.startOffset = Int16(item.highlightData?.range.startOffset ?? -1)

        return model
    }
}
