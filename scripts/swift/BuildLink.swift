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

import Foundation
import swsh
import ArgumentParser

struct BuildLink: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create build links for QR codes in pull requests",
        subcommands: [
            GenerateTempLinks.self,
            UpdateLink.self,
        ]
    )

    enum App: String, CaseIterable, ExpressibleByArgument {
        case student, teacher, parent

        func title(branchDescription: String) -> String {
            "\(rawValue) - \(branchDescription)"
        }
    }

    struct GenerateTempLinks: ParsableCommand {
        @Argument()
        var prNumber: String

        func run() throws {
            guard try getBuildLinkIDs(prID: prNumber) == nil else {
                print("Links already exist, no work to be done")
                return
            }

            let tempUrl = "https://github.com/\(Github.repo)/pull/\(prNumber)"
            var ids: [String] = []
            var links: [String] = []
            for app in App.allCases {
                let result = try Rebrandly.shortenOrUpdate(url: tempUrl, title: app.title(branchDescription: "PR \(prNumber)"))
                ids.append(result.id)
                links.append("\(app): [Link](https://\(result.shortUrl)) | [QR](\(result.qrUrl))")
            }

            let body = """
            <!-- \(magicString): \(ids.joined(separator: " ")) -->
            ## Latest Installable Builds

            (will redirect to this page if no builds exist yet)
            \(links.joined(separator: "\n"))
            """
            try Github.postComment(prID: prNumber, body: body)
        }
    }

    struct UpdateLink: ParsableCommand {
        @Argument(help: "must be one of \(App.allCases.map { $0.rawValue })")
        var app: App

        @Argument()
        var branch: String

        @Argument()
        var url: String

        func run() throws {
            if branch == "master" {
                guard let appIndex = App.allCases.firstIndex(of: app) else {
                    print("Couldn't find build link idendifier!")
                    throw ExitCode.failure
                }
                try Rebrandly.shortenOrUpdate(
                    id: masterLinkIds[appIndex],
                    url: url,
                    title: app.title(branchDescription: "master")
                )
            } else {
                guard let prID = try Github.findAssociatedPullRequests(branch: branch).max() else {
                    print("can't find a pull request associated with branch \(branch)")
                    throw ExitCode.failure
                }
                try updateBuildLink(prID: "\(prID)", app: app, url: url)
            }
        }
    }
    static let magicString = "build-link" + "-magic-string"
    static let masterLinkIds = [
        "5170df518790453cb3c867a36a9befd0",
        "fe339692b8644ce3be6ec62b7f1c7caf",
        "fe13f1e303d545c4aec2118366a7ddfc",
    ]

    enum Rebrandly {
        static let apiKey = Env.env["REBRANDLY_API_KEY"] ?? Env.error("REBRANDLY_API_KEY")

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

    static func getBuildLinkIDs(prID: String) throws -> [String]? {
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

    static func updateBuildLink(prID: String, app: App, url: String) throws {
        guard let ids = try getBuildLinkIDs(prID: prID),
            let appIndex = App.allCases.firstIndex(of: app),
            ids.indices.contains(appIndex) else {
                print("Couldn't find build link idendifier!")
                return
        }
        try Rebrandly.shortenOrUpdate(id: ids[appIndex], url: url, title: app.title(branchDescription: "PR \(prID)"))
    }
}
