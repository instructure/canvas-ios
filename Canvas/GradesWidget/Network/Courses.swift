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

let CoursesCacheKey = "GradesWidgetCacheCoursesKey"

func getCourses(client: CKIClient, completionHandler: @escaping (Result<[Course]>) -> Void) {
    if let cache = loadCache() {
        completionHandler(.completed(cache))
    }

    guard let baseURL = client.baseURL, let token = client.accessToken else {
        completionHandler(.failed(NetworkError.invalidRequest))
        return
    }
    let url = baseURL.appendingPathComponent("api/v1/courses")
    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [
        URLQueryItem(name: "include[]", value: "favorites"),
        URLQueryItem(name: "include[]", value: "total_scores"),
        URLQueryItem(name: "include[]", value: "current_grading_period_scores"),
        URLQueryItem(name: "per_page", value: "99") 
    ]
    var request = URLRequest(url: urlComponents?.url ?? url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json+canvas-string-ids", forHTTPHeaderField: "Accept")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode), let data = data else {
            completionHandler(.failed(error ?? NetworkError.invalidResponse))
            return
        }

        do {
            let decoder = JSONDecoder()
            let courses = try decoder.decode([Course].self, from: data)
            let favorites = courses.filter { $0.isFavorite }
            try writeToCache(favorites)
            completionHandler(.completed(favorites))
            return
        } catch let e {
            completionHandler(.failed(e))
            return
        }
    }

    task.resume()
}

private func loadCache() -> [Course]? {
    guard let coursesData = UserDefaults.standard.data(forKey: CoursesCacheKey) else {
        return nil
    }
    let decoder = JSONDecoder()
    return try? decoder.decode([Course].self, from: coursesData)
}

private func writeToCache(_ courses: [Course]) throws {
    let encoder = JSONEncoder()
    let encoded = try encoder.encode(courses)
    UserDefaults.standard.set(encoded, forKey: CoursesCacheKey)
}
