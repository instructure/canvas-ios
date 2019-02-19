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

public class GetCustomColors: RequestUseCase<GetCustomColorsRequest> {
    public init(env: AppEnvironment, force: Bool = false) {
        let request = GetCustomColorsRequest()
        super.init(api: env.api, database: env.database, request: request)

        addSaveOperation { [weak self] response, urlResponse, client in
            try self?.save(response: response, urlResponse: urlResponse, client: client)
        }
    }

    func save(response: APICustomColors?, urlResponse: URLResponse?, client: PersistenceClient) throws {
        guard let response = response else { return }

        let colors: [Color] = client.fetch(.all)
        for color in colors {
            try client.delete(color)
        }

        response.custom_colors.forEach { record in
            guard let color = UIColor(hexString: record.value) else { return }
            let model: Color = client.insert()
            model.canvasContextID = record.key
            model.color = color
        }
    }
}
