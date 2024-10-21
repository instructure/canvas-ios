//
// This file is part of Canvas.
// Copyright (C) 2836-present  Instructure, Inc.
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
import XCResultKit
import ArgumentParser

struct TestResult: Codable {
    enum CodingKeys: String, CodingKey {
        case duration
        case identifier
        case testStatus
        case `try`
        case finalTry
        case message
    }

    let duration: Double?
    let identifier: String
    let testStatus: String
    let `try`: Int
    let finalTry: Bool
    let message: String?

    let eventType: String = "testResult"
    let workflow = Env.env["BITRISE_TRIGGERED_WORKFLOW_TITLE"]
    let build = Env.env["BITRISE_BUILD_URL"]
    let branch = Env.env["BITRISE_GIT_BRANCH"]
    let commit = Env.env["BITRISE_GIT_COMMIT"]
}

struct SummarizeTestResults: ParsableCommand {
    @Argument()
    var xctestrun: String

    func run() throws {
        let resultFile = XCResultFile(url: NSURL.fileURL(withPath: xctestrun))

        func getTests(group: ActionTestSummaryGroup) -> [ActionTestMetadata] {
            group.subtests + group.subtestGroups.flatMap(getTests)
        }

        let testRunIds = resultFile.getInvocationRecord()!.actions.compactMap { $0.actionResult.testsRef?.id }

        var results = [TestResult]()

        for (tryNumber, testRunId) in testRunIds.enumerated() {
            let isFinal = testRunId == testRunIds.last
            let bundleSummaries = resultFile.getTestPlanRunSummaries(id: testRunId)!.summaries
            for bundleSummary in bundleSummaries.flatMap({ $0.testableSummaries }) {
                for group in bundleSummary.tests {
                    for test in getTests(group: group) {
                        var message: String?

                        if test.testStatus != "Success",
                           let ref = test.summaryRef,
                           let summary = resultFile.getActionTestSummary(id: ref.id) {

                            var titles = summary.activitySummaries.map { $0.title }
                            if titles.isEmpty {
                                titles = summary.failureSummaries.compactMap { $0.message }
                            }
                            message = titles.joined(separator: "\n")
                        }

                        if let testId = test.identifier?.trimmingCharacters(in: CharacterSet(charactersIn: "()")) {
                            let fullTestId = (bundleSummary.targetName ?? "") + "/" + testId

                            results.append(TestResult(
                                             duration: test.duration,
                                             identifier: fullTestId,
                                             testStatus: test.testStatus,
                                             try: tryNumber,
                                             finalTry: isFinal,
                                             message: message))
                        }
                    }
                }
            }
        }

        for result in results {
            let json = try JSONEncoder().encode(result)
            print(String(data: json, encoding: .utf8)!)
        }

        // Turn any text into a markdown code block
        func codeBlock(_ str: String) -> String {
            var lines = ["", ""]
            str.enumerateLines { line, _ in
                lines.append("    \(line)")
            }
            return lines.joined(separator: "\n")
        }

        // Report failures to danger
        try FileManager.default.createDirectory(atPath: "tmp", withIntermediateDirectories: true)
        let dangerOut = OutputStream(toFileAtPath: "tmp/report_to_danger.md", append: true)!
        dangerOut.open()
        defer { dangerOut.close() }

        func reportToDanger(_ message: String) {
            let data = "\(message)\n".data(using: .utf8)!
            _ = data.withUnsafeBytes {
                dangerOut.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
            }
        }

        let failures = results.filter({ $0.testStatus == "Failure" })
        let maxReportCount = 10
        for result in failures.prefix(10) {
            let headline = ":x: XCTest failed: \(result.identifier)"
            if let message = result.message {
                reportToDanger("""
                                 <details><summary>\(headline.withEscapedHTML)</summary>
                                 \(codeBlock(message))
                                 </details>
                                 """)
            } else {
                reportToDanger(headline.withEscapedHTML)
            }
        }

        if failures.count > maxReportCount {
            reportToDanger(":x: (and \(failures.count - maxReportCount) other test failures)")
        }
    }
}
