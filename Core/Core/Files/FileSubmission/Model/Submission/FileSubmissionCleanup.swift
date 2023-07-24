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

import Combine
import CoreData

public class FileSubmissionCleanup {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    func clean(fileSubmissionID: NSManagedObjectID) -> Future<Void, Never> {
        Future<Void, Never> { [context] promise in
            context.perform {
                defer { promise(.success(())) }

                guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else {
                    return
                }

                for item in submission.files {
                    try? FileManager.default.removeItem(at: item.localFileURL)
                }
            }
        }
    }
}
