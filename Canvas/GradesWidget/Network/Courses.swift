//
//  Courses.swift
//  GradesWidget
//
//  Created by Nathan Armstrong on 1/9/18.
//  Copyright © 2018 Instructure. All rights reserved.
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
