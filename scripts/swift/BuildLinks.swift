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

struct BuildLinks: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create build links for QR codes in pull requests"
    )

    lazy var installPageMap =
        Env.env["BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP"] ??
        Env.error("BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP")

    @Argument()
    var branch: String

    mutating func run() throws {
        ExternalCommand.verbose = true
        let apps = installPageMap.components(separatedBy: "|")
          .map { (x: String) -> [String] in x.components(separatedBy: "=>") }
          .compactMap { (mapping: [String]) -> (file: String, url: String)? in
              guard mapping.count == 2 else {
                  return nil
              }
              let file = mapping[0].components(separatedBy: "/").last!
              let url = mapping[1]
              return (file: file, url: url)
          }

        var body = "<!-- \(magicString) -->"
        for app in apps {
            let allowedChars = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "?&"))
            let escapedUrl = app.url.addingPercentEncoding(withAllowedCharacters: allowedChars)!
            body += """

                <details><summary>\(app.file)</summary>
                [![QR for \(app.file) install](https://api.qrserver.com/v1/create-qr-code/?data=\(escapedUrl))](\(app.url))
                </details>
                """
        }

        guard let prID = try Github.findAssociatedPullRequests(branch: branch).max() else {
            print("can't find a pull request associated with branch \(branch)")
            throw ExitCode.failure
        }
        if let commentID = try getCommentID(prID: "\(prID)") {
            try Github.updateComment(commentID: commentID, body: body)
        } else {
            try Github.postComment(prID: "\(prID)", body: body)
        }
    }

    let magicString = "build-link" + "-magic-string"

    func getCommentID(prID: String) throws -> String? {
        let comments = try Github.getAllIssueComments(prID: prID)
        for comment in comments {
            let body = comment.body
            guard comment.user.login == "inst-danger",
                  body.hasPrefix("<!-- \(magicString) -->") else {
                continue
            }
            return "\(comment.id)"
        }
        return nil
    }
}
