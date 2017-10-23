//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import Result

import ReactiveSwift
import Marshal

internal enum BackdropError: Int {
    case jsonParse
    case unknownError
    case badFile
}

private typealias JSONString = String

// DON'T CHANGE THESE! THE FATE OF THE WORLD DEPENDS ON IT!
private let backdropNamespace = "MOBILE_CANVAS_USER_BACKDROP_IMAGE"
private let backdropScope = "data_sync"
private let customDataKey = "data"
private let namespaceKey = "ns"

private let backdropParseResponse: (JSONObject) -> Result<JSONString, NSError> = {json in
    if let json = json as? [String: JSONString] {
        if let uglyString = json[customDataKey] {
            let result: Result<JSONString, NSError> = Result(value: uglyString)
            return result
        }
    }
    let error = NSError(domain: "ProfileKit.BackdropServerHandling.backdropParseResponse", code: BackdropError.jsonParse.rawValue, userInfo: [NSLocalizedDescriptionKey: "can't parse json"])
    let result: Result<JSONString, NSError> = Result(error: error)
    return result
}

private func customDataBackdropPath() -> String {
    return api/v1/"users"/"self"/"custom_data"/backdropScope
}

/**
Change the value in the UserCustomDataStore to a certain BackdropFile. Value
is shared with Android so it's critically important that we don't change
the formatting of the JSON.
*/
internal func setBackdropOnServer(_ file: BackdropFile?, session: Session) ->SignalProducer<BackdropFile?, NSError> {
    
    guard let data = BackdropFile.JSONForFile(file) else { return SignalProducer.empty }
    let parameters: [String: Any] = [namespaceKey: backdropNamespace, customDataKey: data]
    
    let path = customDataBackdropPath()
    let parseResponse = backdropParseResponse
    
    return attemptProducer { try session.PUT(path, parameters: parameters) }
        .flatMap(.merge, transform: session.JSONSignalProducer)
        .attemptMap(parseResponse)
        .attemptMap(BackdropFile.fromJSON)
}

/**
Get and Read the JSON stored in the UserCustomDataStore for the Backdrop preferences for 
a certain user. Return the selected Backdrop as a BackdropFile.
*/
internal func getBackdropOnServer(_ session: Session) -> SignalProducer<BackdropFile?, NSError> {
    let path = customDataBackdropPath()
    let parseResponse = backdropParseResponse
    let parameters = [namespaceKey: backdropNamespace]
    return attemptProducer { try session.GET(path, parameters: parameters) }
        .flatMap(.merge, transform: session.JSONSignalProducer)
        .attemptMap(parseResponse)
        .attemptMap(BackdropFile.fromJSON)
        .flatMapError { _ in SignalProducer(value: nil) }
}











