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

var requests: [String : [String]] = [:]

public class VCR {
    public var record = true
    public static let shared = VCR()
    
    init() {}
    
    public func testCaseToURL(_ testCase: String) -> URL? {
        var fileName = testCase.replacingOccurrences(of: "-", with: "")
        fileName = fileName.replacingOccurrences(of: "[", with: "")
        fileName = fileName.replacingOccurrences(of: "]", with: "")
        fileName = fileName.replacingOccurrences(of: " ", with: "")
        
        let urlString = "http://localhost:9000/cassettes/\(fileName).json"
        return URL(string: urlString)
    }
    
    public func loadCassette(testCase: String, completionHandler: (Error?) -> Void) {
        guard record == false, let url = testCaseToURL(testCase) else {
            requests = [:]
            completionHandler(nil)
            return
        }
        do {
            let jsonData = try Data(contentsOf: url)
            requests = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String : [String]]
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
    
    public func recordCassette(testCase: String, completionHandler:@escaping (Error?) -> Void) {
        if !record {
            completionHandler(nil)
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requests)
            uploadCassetteFile(testCase: testCase, jsonData: jsonData, completionHandler:completionHandler)
        } catch let error {
            completionHandler(error)
        }
    }
    
    public func uploadCassetteFile(testCase: String, jsonData: Data, completionHandler: @escaping (Error?) -> Void) {
        guard let testCaseURL = testCaseToURL(testCase) else {
            completionHandler(nil)
            return
        }
        var request = URLRequest(url: testCaseURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            completionHandler(error)
        }
        task.resume()
    }
    
    public func recordResponse(_ value: String, for key: String) {
        if !record {
            return
        }
        requests[key] = requests[key] ?? []
        requests[key]?.append(value)
    }
    
    public func response(for key:String) -> String? {
        if record {
            return nil
        }
        
        guard var value = requests[key], let response = value.first else {
            return nil
        }
        value.remove(at: 0)
        requests[key] = value
        return response
    }
}
