#!/usr/bin/swift sh
//
// This file is part of Canvas.
// Copyright (C) 2836-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 4 of the
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

// Note, swift-sh should be installed to resolve dependencies
//   brew install mxcl/made/swift-sh

// To edit this file in xcode:
//   swift sh edit summarize-test-results.swift

import Foundation
import XCResultKit // @cobbal == dev

let env = ProcessInfo.processInfo.environment

struct TestResult: Codable {
    let eventType: String = "testResult"
    let duration: Double?
    let identifier: String
    let testStatus: String
    let `try`: Int
    let finalTry: Bool
    let workflow = env["BITRISE_TRIGGERED_WORKFLOW_TITLE"]
    let build = env["BITRISE_BUILD_URL"]
    let branch = env["BITRISE_GIT_BRANCH"]
    let commit = env["BITRISE_GIT_COMMIT"]
    let message: String?
}

if CommandLine.argc != 2 {
    print("usage: summarize-test-results.swift result.xctestrun")
    exit(1)
}
let resultFile = XCResultFile(url: NSURL.fileURL(withPath: CommandLine.arguments[1]))

func getTests(group: ActionTestSummaryGroup) -> [ActionTestMetadata] {
    group.subtests + group.subtestGroups.flatMap(getTests)
}

let testIds = resultFile.getInvocationRecord()!.actions.compactMap { $0.actionResult.testsRef?.id }

for (`try`, id) in testIds.enumerated() {
    let isFinal = id == testIds.last
    for bundleSummary in resultFile.getTestPlanRunSummaries(id: id)!.summaries.flatMap({ $0.testableSummaries }) {
        for group in bundleSummary.tests {
            for test in getTests(group: group) {
                var message: String? = nil

                if test.testStatus != "Success",
                   let ref = test.summaryRef,
                   let summary = resultFile.getActionTestSummary(id: ref.id) {

                    var titles = summary.activitySummaries.map { $0.title }
                    if titles.isEmpty {
                        titles = summary.failureSummaries.compactMap { $0.message }
                    }
                    message = titles.joined(separator: "\n")
                }

                let identifier = (bundleSummary.targetName ?? "") + "/" + test.identifier.trimmingCharacters(in: CharacterSet(charactersIn: "()"))

                let result = TestResult(
                    duration: test.duration,
                    identifier: identifier,
                    testStatus: test.testStatus,
                    try: `try`,
                    finalTry: isFinal,
                    message: message)

                let json = try! JSONEncoder().encode(result)
                print(String(data: json, encoding: .utf8)!)
            }
        }
    }
}
