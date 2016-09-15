//
//  UserCustomData.swift
//  iCanvas
//
//  Created by Nathan Perry on 7/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import Result
import TooLegit
import ReactiveCocoa
import Marshal

internal enum BackdropError: Int {
    case JSONParse
    case UnknownError
    case BadFile
}

private typealias JSONString = String

// DON'T CHANGE THESE! THE FATE OF THE WORLD DEPENDS ON IT!
private let backdropNamespace = "MOBILE_CANVAS_USER_BACKDROP_IMAGE"
private let backdropScope = "data_sync"
private let customDataKey = "data"
private let namespaceKey = "ns"

private let backdropParseResponse: JSONObject -> Result<JSONString, NSError> = {json in
    if let json = json as? [String: JSONString] {
        if let uglyString = json[customDataKey] {
            let result: Result<JSONString, NSError> = Result(value: uglyString)
            return result
        }
    }
    let error = NSError(domain: "ProfileKit.BackdropServerHandling.backdropParseResponse", code: BackdropError.JSONParse.rawValue, userInfo: [NSLocalizedDescriptionKey: "can't parse json"])
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
internal func setBackdropOnServer(file: BackdropFile?, session: Session) ->SignalProducer<BackdropFile?, NSError> {
    
    guard let data = BackdropFile.JSONForFile(file) else { return SignalProducer.empty }
    let parameters: [String: AnyObject] = [namespaceKey: backdropNamespace, customDataKey: data]
    
    let path = customDataBackdropPath()
    let parseResponse = backdropParseResponse
    
    return attemptProducer { try session.PUT(path, parameters: parameters) }
        .flatMap(.Merge, transform: session.JSONSignalProducer)
        .attemptMap(parseResponse)
        .attemptMap(BackdropFile.fromJSON)
}

/**
Get and Read the JSON stored in the UserCustomDataStore for the Backdrop preferences for 
a certain user. Return the selected Backdrop as a BackdropFile.
*/
internal func getBackdropOnServer(session: Session) -> SignalProducer<BackdropFile?, NSError> {
    let path = customDataBackdropPath()
    let parseResponse = backdropParseResponse
    let parameters = [namespaceKey: backdropNamespace]
    return attemptProducer { try session.GET(path, parameters: parameters) }
        .flatMap(.Merge, transform: session.JSONSignalProducer)
        .attemptMap(parseResponse)
        .attemptMap(BackdropFile.fromJSON)
        .flatMapError { _ in SignalProducer(value: nil) }
}











