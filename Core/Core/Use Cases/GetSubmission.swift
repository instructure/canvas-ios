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

public class GetSubmission: RequestUseCase<GetSubmissionRequest> {
    let context: Context
    let assignmentID: String
    let userID: String

    public init(context: Context, assignmentID: String, userID: String, env: AppEnvironment) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        let request = GetSubmissionRequest(context: context, assignmentID: assignmentID, userID: userID)
        super.init(api: env.api, database: env.database, request: request)
        addSaveOperation { [weak self] response, urlResponse, client in
            try self?.save(response: response, urlResponse: urlResponse, client: client)
        }
    }

    func save(response: APISubmission?, urlResponse: URLResponse?, client: PersistenceClient) throws {
        guard let item = response else { return }
        let mainPredicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(Submission.assignmentID), assignmentID,
            #keyPath(Submission.userID), userID
        )
        let mainSort = NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: false)
        let model: Submission = client.fetch(predicate: mainPredicate, sortDescriptors: [ mainSort ]).first ?? client.insert()
        try model.update(fromApiModel: item, in: client)
        for entry in item.submission_history ?? [] {
            let predicate = NSPredicate(
                format: "%K == %@ AND %K == %@ AND %K == %d",
                #keyPath(Submission.assignmentID), assignmentID,
                #keyPath(Submission.userID), userID,
                #keyPath(Submission.attempt), entry.attempt ?? 0
            )
            let historical: Submission = client.fetch(predicate: predicate, sortDescriptors: nil).first ?? client.insert()
            try historical.update(fromApiModel: entry, in: client)
        }
    }
}
