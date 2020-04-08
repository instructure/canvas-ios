#!/usr/bin/swift sh
//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

// Create build links for QR codes in pull requests
//
// Note, swift-sh should be installed to resolve dependencies
//   brew install mxcl/made/swift-sh
//
// To edit this file in xcode:
//   swift sh edit build-link.swift

import Foundation
import swsh // @cobbal == 0.2.0

let repoOwner = "instructure"
let repoName = "canvas-ios"
let repo = "\(repoOwner)/\(repoName)"
let magicString = "build-link" + "-magic-string"
let masterLinkIds = [
  "5170df518790453cb3c867a36a9befd0",
  "fe339692b8644ce3be6ec62b7f1c7caf",
  "fe13f1e303d545c4aec2118366a7ddfc",
]

enum App: String, CaseIterable {
    case student, teacher, parent

    func title(branchDescription: String) -> String {
        "\(self) - \(branchDescription)"
    }

}

let env = ProcessInfo.processInfo.environment

enum Github {
    static var token: String {
        if let token = env["DANGER_GITHUB_API_TOKEN"] {
            return token
        }
        if let token = env["GITHUB_ACCESS_TOKEN"] {
            return token
        }
        print("environment variable DANGER_GITHUB_API_TOKEN must be set")
        exit(1)
    }

    struct IssueComment: Codable {
        let body: String
        let user: User

        struct User: Codable {
            let login: String
        }
    }

    static func getAllIssueComments(prID: String) throws -> [IssueComment] {
        // TODO: paging, but it'll probably be in the first page, right?
        let url = "https://api.github.com/repos/\(repo)/issues/\(prID)/comments"
        return try cmd(
            "curl", "-sf", url,
            "-H", "Authorization: Bearer \(token)"
        ).runJson([IssueComment].self)
    }

    static func postComment(prID: String, body: String) throws {
        try cmd(
            "curl", "-sf", "https://api.github.com/repos/\(repo)/issues/\(prID)/comments",
            "-X", "POST",
            "-H", "Content-Type: application/json; charset=utf-8",
            "-H", "Authorization: Bearer \(token)",
            "--data-binary", "@-"
        ).input(withJSONObject: [ "body": body ]).run()
    }

    static func findAssociatedPullRequests(branch: String) throws -> [Int] {
        let query = """
        query findAssociatedPullRequests($branch: String!) {
            repository(owner: "instructure", name: "canvas-ios") {
                ref(qualifiedName: $branch) {
                    target { ... on Commit {
                        associatedPullRequests(first: 10) {
                            nodes { number closed } } } } } } }
        """
        let result = try cmd(
            "curl", "-sf", "https://api.github.com/graphql",
            "-X", "POST",
            "-H", "Authorization: Bearer \(token)",
            "--data-binary", "@-"
        ).input(withJSONObject: [
            "query": query,
            "variables": [ "branch": branch ],
        ]).runJson()

        let keyPath = "data.repository.ref.target.associatedPullRequests.nodes"
        guard let nodes = (result as? NSDictionary)?.value(forKeyPath: keyPath) as? [[String: Any]] else {
            fatalError("Couldn't parse response from graphql" )
        }
        return nodes.compactMap { node in
            guard node["closed"] as? Bool == false else { return nil }
            return node["number"] as? Int
        }
    }
}

enum Rebrandly {
    static var apiKey: String {
        if let token = env["REBRANDLY_API_KEY"] {
            return token
        }
        print("environment variable REBRANDLY_API_KEY must be set")
        exit(1)
    }

    struct ShortenResponse: Codable {
        let id: String
        let shortUrl: String
        var qrUrl: String {
            let encoded = shortUrl.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            return "https://qr.rebrandly.com/v1/qrcode?shortUrl=\(encoded)"
        }
    }

    @discardableResult
    static func shortenOrUpdate(id: String? = nil, url: String, title: String = "unknown") throws -> ShortenResponse {
        var apiUrl = "https://api.rebrandly.com/v1/links"
        if let id = id {
            apiUrl.append("/" + id)
        }
        return try cmd(
            "curl", "-sf", apiUrl,
            "-X", "POST",
            "-H", "Content-Type: application/json; charset=utf-8",
            "-H", "apikey: \(apiKey)",
            "--data-binary", "@-"
        ).input(withJSONObject: [
            "title": title,
            "destination": url,
        ]).runJson(ShortenResponse.self)
    }

    static func getLinkDetails(id: String) throws -> ShortenResponse {
        print(try cmd(
            "curl", "-sf", "https://api.rebrandly.com/v1/links/\(id)",
            "-H", "apikey: \(apiKey)"
        ).runString())
        return try cmd(
            "curl", "-sf", "https://api.rebrandly.com/v1/links/\(id)",
            "-H", "apikey: \(apiKey)"
        ).runJson(ShortenResponse.self)
    }
}

func getBuildLinkIDs(prID: String) throws -> [String]? {
    let comments = try Github.getAllIssueComments(prID: prID)
    let matches: [[String]] = try comments.compactMap { comment in
        let body = comment.body
        guard comment.user.login == "inst-danger" else { return nil }
        let extractor = try NSRegularExpression(pattern: "<!-- \(magicString): (([^ -]+ )*)-->", options: [])
        let range = NSRange(body.startIndex..<body.endIndex, in: body)
        guard let match = extractor.firstMatch(in: body, options: [], range: range) else {
            return nil
        }
        let linkRange = match.range(at: 1)
        return body[Range(linkRange, in: body)!].split(separator: " ", omittingEmptySubsequences: true).map(String.init)
    }
    return matches.first
}

func createBuildLinks(prID: String) throws {
    guard try getBuildLinkIDs(prID: prID) == nil else {
        print("Links already exist, no work to be done")
        return
    }

    let tempUrl = "https://github.com/\(repo)/pull/\(prID)"
    var ids: [String] = []
    var links: [String] = []
    for app in App.allCases {
        let result = try Rebrandly.shortenOrUpdate(url: tempUrl, title: app.title(branchDescription: "PR \(prID)"))
        ids.append(result.id)
        links.append("\(app): [Link](https://\(result.shortUrl)) | [QR](\(result.qrUrl))")
    }

    let body = """
        <!-- \(magicString): \(ids.joined(separator: " ")) -->
        ## Latest Installable Builds

        (will redirect to this page if no builds exist yet)
        \(links.joined(separator: "\n"))
        """
    try Github.postComment(prID: prID, body: body)
}

func updateBuildLink(prID: String, app: App, url: String) throws {
    guard let ids = try getBuildLinkIDs(prID: prID),
        let appIndex = App.allCases.firstIndex(of: app),
        ids.indices.contains(appIndex) else {
        print("Couldn't find build link idendifier!")
        return
    }
    try Rebrandly.shortenOrUpdate(id: ids[appIndex], url: url, title: app.title(branchDescription: "PR \(prID)"))
}

let usage = """
usage:
    ./scripts/build_automation/build-link.swift generate-temp-links PR_NUMBER
    ./scripts/build_automation/build-link.swift update-link student|teacher|parent BRANCH URL
"""

let args = CommandLine.arguments
if args.count == 3, args[1] == "generate-temp-links" {
    let prId = args[2]
    try createBuildLinks(prID: prId)
} else if args.count == 5, args[1] == "update-link",
    let app = App(rawValue: args[2]) {

    let branch = args[3]
    let url = args[4]
    if branch == "master" {
        guard let appIndex = App.allCases.firstIndex(of: app) else {
            print("Couldn't find build link idendifier!")
            exit(1)
        }
        try Rebrandly.shortenOrUpdate(
          id: masterLinkIds[appIndex],
          url: url,
          title: app.title(branchDescription: "master")
        )
    } else {
        guard let prID = try Github.findAssociatedPullRequests(branch: branch).max() else {
            print("can't find a pull request associated with branch \(branch)")
            exit(1)
        }
        try updateBuildLink(prID: "\(prID)", app: app, url: url)
    }
} else {
    print(usage)
    exit(1)
}
