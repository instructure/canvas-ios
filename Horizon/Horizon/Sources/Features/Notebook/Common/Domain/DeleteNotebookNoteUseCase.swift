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

class DeleteNotebookNoteUseCase: DeleteUseCase {
    var cacheKey: String?

    typealias Model = CDHNotebookNote

    // MARK: Dependencies
    let redwood: DomainService

    // MARK: Overridden Properties
    let request: RedwoodDeleteNoteMutation

    public var scope: Scope {
        Scope(predicate: NSPredicate(format: "%K == %@", #keyPath(CDHNotebookNote.id), request.variables.id), order: [])
    }

    // MARK: Private Properties
    private var subscriptions = Set<AnyCancellable>()

    // MARK: Init
    init(request: RedwoodDeleteNoteMutation, redwood: DomainService = DomainService(.redwood)) {
        self.request = request
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
}
