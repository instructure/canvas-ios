//
//  PathToRegexp.swift
//  Core
//
//  Created by Matt Sessions on 8/14/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

let parserPattern = "(\\\\.)|(?:\\:(\\w+)(?:\\(((?:\\\\.|[^\\\\()])+)\\))?|\\(((?:\\\\.|[^\\\\()])+)\\))([+*?])?"

struct Token {
    public let name: String
    public let prefix: String
    public let delimiter: String
    public let optional: Bool
    public let repeatable: Bool
    public let partial: Bool
    public let pattern: String
}

//  swiftlint:disable function_body_length
func parse (_ str: String) -> [Any] {
    let defaultDelimiter = "/"
    let defaultDelimiters = "./"
    var tokens: [Any] = []
    var key = 0
    var index = 0
    var path = ""
    var pathEscaped = false

    if let parserExpression = try? NSRegularExpression(pattern: parserPattern, options: .caseInsensitive) {
        let matches = parserExpression.matches(in: str, range: NSRange(location: 0, length: str.count))

        for match in matches {
            guard let stringMatch = substringFromRange(match.range(at: 0), in: str) else { continue }
            let escaped = substringFromRange(match.range(at: 1), in: str)
            let offset = match.range.lowerBound
            let start = str.index(str.startIndex, offsetBy: index)
            let end = str.index(str.startIndex, offsetBy: offset)
            path += str[start..<end]
            index = offset + stringMatch.count

            if let escaped = escaped {
                let start = str.index(escaped.startIndex, offsetBy: 1)
                let end = str.index(escaped.startIndex, offsetBy: 2)
                path += escaped[start..<end]
                pathEscaped = true
                continue
            }

            var prev = ""
            let next = String(str[start])
            let name = substringFromRange(match.range(at: 2), in: str)
            if name == nil {
                key += 1
            }
            let capture = substringFromRange(match.range(at: 3), in: str)
            let group = substringFromRange(match.range(at: 4), in: str)
            let modifier = substringFromRange(match.range(at: 5), in: str)

            if !pathEscaped && path.count > 0 {
                if let lastChar = path.last, defaultDelimiters.contains(lastChar) {
                    prev = String(lastChar)
                    path = String(path[path.startIndex..<path.index(before: path.endIndex)])
                }
            }

            if path.count > 0 {
                tokens.append(path)
                path = ""
                pathEscaped = false
            }

            let partial = prev.isEmpty && next.isEmpty && next != prev
            let repeatable = modifier == "+" || modifier == "*"
            let optional = modifier == "?" || modifier == "*"
            let delimiter = prev.isEmpty ? defaultDelimiter : prev
            let pattern = capture ?? group

            tokens.append(Token(
                name: name ?? String(key),
                prefix: prev,
                delimiter: delimiter,
                optional: optional,
                repeatable: repeatable,
                partial: partial,
                pattern: pattern != nil ? escapeGroup(pattern!) : "[^" + escapeString(delimiter) + "]+?"
            ))
        }
    }

    if path.count > 0 || index < str.count {
        tokens.append(path + str[str.index(str.startIndex, offsetBy: index)...])
    }

    return tokens
}
//  swiftlint:enable function_body_length

func escapeGroup(_ group: String) -> String {
    guard let replacementRegExp = try? NSRegularExpression(pattern: "([=!:$/()])", options: .caseInsensitive) else { return group }
    guard let match = replacementRegExp.firstMatch(in: group, range: NSRange(location: 0, length: group.count)) else { return group }
    let range = match.range(at: 0)
    guard let swiftRange = Range(range, in: group), let substring = substringFromRange(range, in: group) else { return group }
    var groupCopy = group
    groupCopy.replaceSubrange(swiftRange, with: substring)
    return groupCopy
}

func escapeString(_ str: String) -> String {
    guard let replacementRegExp = try? NSRegularExpression(pattern: "([\\.\\+\\*\\?=\\^!:\\$\\{\\}\\(\\)\\[]|\\/\\])", options: .caseInsensitive),
        let match = replacementRegExp.firstMatch(in: str, range: NSRange(location: 0, length: str.count)) else { return str }
    let range = match.range(at: 0)
    guard let swiftRange = Range(range, in: str), let substring = substringFromRange(range, in: str) else { return str }
    var strCopy = str
    strCopy.replaceSubrange(swiftRange, with: substring)
    return strCopy
}

func substringFromRange(_ range: NSRange, in input: String) -> String? {
    guard let matchingRange = Range(range, in: input) else { return nil }
    return String(input[matchingRange])
}

func tokensToRegExp (tokens: [Any]) -> NSRegularExpression? {
    var route = ""

    for token in tokens {
        if let token = token as? String {
            route += escapeString(token)
        } else if let token = token as? Token {
            let prefix = escapeString(token.prefix)
            let capture = token.repeatable
                ? "(?:" + token.pattern + ")(?:" + prefix + "(?:" + token.pattern + "))*"
                : token.pattern

            if token.optional {
                if token.partial {
                    route += prefix + "(" + capture + ")?"
                } else {
                    route += "(?:" + prefix + "(" + capture + "))?"
                }
            } else {
                route += prefix + "(" + capture + ")"
            }
        }
    }

    route += "$"

    return try? NSRegularExpression(pattern: "^" + route, options: .caseInsensitive)
}

public func pathToRegexp (_ path: String) -> NSRegularExpression? {
    let tokens = parse(path)
    return tokensToRegExp(tokens: tokens)
}

public func extractParamsFromPath(_ path: String, match: NSTextCheckingResult, routePath: String) -> [String: String] {
    let path = String(path.split(separator: "?")[0])
    let parserExpression = try? NSRegularExpression(pattern: parserPattern, options: .caseInsensitive)
    let routeMatches = parserExpression?.matches(in: routePath, range: NSRange(location: 0, length: routePath.count))

    var params: [String: String] = [:]
    guard let matches = routeMatches else { return params }
    for (index, routeMatch) in matches.enumerated() {
        guard let paramName = substringFromRange(routeMatch.range(at: 2), in: routePath), let paramValue = substringFromRange(match.range(at: index + 1), in: path) else { continue }
        params[paramName] = paramValue
    }

    return params
}

public func extractQueryParamsFromPath(_ path: String) -> [String: String] {
    guard let url = URL(string: path), let queryString = url.query else { return [:] }

    var queryParams: [String: String] = [:]
    let queries = queryString.split(separator: "&")
    for query in queries {
        let keyValue = query.split(separator: "=")
        guard let key = String(keyValue[0]).removingPercentEncoding, let value = String(keyValue[1]).replacingOccurrences(of: "+", with: " ").removingPercentEncoding else { continue }
        queryParams[key] = value
    }
    return queryParams
}
