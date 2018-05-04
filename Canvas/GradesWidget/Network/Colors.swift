//
// Copyright (C) 2016-present Instructure, Inc.
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
import CanvasKeymaster

let CustomColorsCacheKey = "GradesWidgetCacheCustomColorsKey"

func getCourseColors(client: CKIClient, completionHandler: @escaping (Result<CustomColors>) -> Void) {
    if let cache = loadCache() {
        completionHandler(.completed(cache))
    }

    guard let baseURL = client.baseURL, let token = client.accessToken else {
        completionHandler(.failed(NetworkError.invalidRequest))
        return
    }
    let url = baseURL.appendingPathComponent("api/v1/users/self/colors")
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode), let data = data else {
            completionHandler(.failed(error ?? NetworkError.invalidResponse))
            return
        }

        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(CustomColors.self, from: data)
            UserDefaults.standard.set(data, forKey: CustomColorsCacheKey)
            completionHandler(.completed(result))
        } catch let e {
            completionHandler(.failed(e))
            return
        }
    }

    task.resume()
}

private func parse(_ data: Data) throws -> CustomColors  {
    let decoder = JSONDecoder()
    return try decoder.decode(CustomColors.self, from: data)
}


private func loadCache() -> CustomColors? {
    guard let data = UserDefaults.standard.data(forKey: CustomColorsCacheKey) else {
        return nil
    }
    let decoder = JSONDecoder()
    return try? decoder.decode(CustomColors.self, from: data)
}
