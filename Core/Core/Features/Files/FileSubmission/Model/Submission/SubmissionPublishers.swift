//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

enum SubmissionPublishers {

    /** Fetching the proper base URL for submission, by investigating course tabs full_url property. */
    static func fetchDestinationBaseURL(fileSubmissionID: NSManagedObjectID, api: API, context: NSManagedObjectContext) -> Future<URL?, Never> {

        return Future<URL?, Never> { [weak api, weak context] promise in
            guard let api, let context else { return promise(.success(nil)) }

            guard let submission = try? context.performAndWait({
                return try context.existingObject(with: fileSubmissionID) as? FileSubmission
            }) else { return promise(.success(nil)) }

            let request = GetContextTabs(context: .course(submission.courseID)).request
            api.makeRequest(request) { response, _, _ in
                guard let baseUrl = response?.first?.full_url?.apiBaseURL else {
                    return promise(.success(nil))
                }
                return promise(.success(baseUrl))
            }
        }
    }
}
