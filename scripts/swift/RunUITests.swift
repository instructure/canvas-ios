//
// This file is part of Canvas.
// Copyright (C) 2835-present  Instructure, Inc.
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
import swsh
import ArgumentParser

private let resultsDirectory = "ui-test-results"
private func resultPath(for name: String) -> String {
    "\(resultsDirectory)/\(name)"
}

struct RunUITests: ParsableCommand {
    @Option(default: "NightlyTests")
    var scheme: String

    @Option(default: "iPhone 8")
    var deviceName: String

    @Flag(help: "build test target first")
    var build: Bool

    @Flag(help: "append to ui-test-results instead of clobbering it")
    var appendResults: Bool

    @Flag(help: "run all tests in scheme")
    var allTests: Bool

    @Argument(help: "tests/suites to run")
    var tests: [String]

    func validate() throws {
        guard build || !tests.isEmpty || allTests else {
            throw ValidationError("specify \"--build\" and/or tests to run")
        }
    }

    func run() throws {
        try Runner(self).run()
    }

    class Runner {
        let command: RunUITests
        struct InternalError: Error, CustomStringConvertible {
            var description: String
        }

        let testRunId = UUID()

        var skipTest: [String: [String]] = [:]
        var onlyTest: [String: [String]] = [:]

        var deployDir: String {
            Env.env["BITRISE_DEPLOY_DIR"] ?? resultsDirectory
        }

        struct BaseTestRun: Codable {
            let buildDir: String
            let testRun: String

            init(buildDir: String, testRun: String) {
                self.buildDir = buildDir
                self.testRun = testRun
            }

            func load() throws -> XCTestRun {
                let data = try Data(contentsOf: URL(fileURLWithPath: "\(buildDir)/\(testRun)"))
                return try PropertyListDecoder().decode(XCTestRun.self, from: data)
            }
        }
        var baseTestRun: BaseTestRun!

        func parse(testId: String) -> (String, String) {
            let parts = testId.split(separator: "/")
            return (String(parts[0]), parts.dropFirst().joined(separator: "/"))
        }

        init(_ command: RunUITests) {
            self.command = command

            for test in command.tests {
                let (suite, testName) = parse(testId: test)
                onlyTest[suite] = onlyTest[suite] ?? []
                if !testName.isEmpty {
                    onlyTest[suite]!.append(testName)
                }
            }
        }

        func run() throws {
            ExternalCommand.verbose = true

            try cmd("mkdir", "-p", "tmp").run()
            try cmd("touch", "tmp/timestamp").run()
            Darwin.setenv("NSUnbufferedIO", "YES", 1)

            try? cmd("xcrun", "simctl", "boot", command.deviceName).run()
            try cmd("open", "-a", cmd("xcode-select", "-p").runString() + "/Applications/Simulator.app").run()

            if !command.appendResults {
                try cmd("rm", "-rf", resultsDirectory).run()
            }
            try cmd("mkdir", "-p", resultsDirectory).run()

            if command.build {
                banner("Building \(command.scheme)")
                try (xcodebuild("build-for-testing") | xcpretty(quiet: true)).run()
            }

            if command.tests.isEmpty && !command.allTests {
                return
            }

            let buildDir = try (
                xcodebuild("-showBuildSettings", "build-for-testing", "-json") |
                    cmd("jq", ".[0].buildSettings.BUILD_DIR")
                ).runJSON(String.self)

            let builtTestRuns = try FileManager.default.contentsOfDirectory(atPath: buildDir).filter {
                $0.hasPrefix(command.scheme) &&
                    $0.range(of: #"_.*_iphonesimulator.*\.xctestrun"#, options: .regularExpression) != nil
            }
            if builtTestRuns.count < 1 {
                throw InternalError(description: "couldn't find xctestrun product")
            } else if builtTestRuns.count > 1 {
                throw InternalError(description: "couldn't determine unique xctestrun product. try cleaning")
            } else {
                baseTestRun = BaseTestRun(buildDir: buildDir, testRun: builtTestRuns.first!)
            }

            if command.allTests {
                for configuration in try baseTestRun.load().TestConfigurations {
                    for target in configuration.TestTargets {
                        onlyTest[target.BlueprintName] = []
                    }
                }
            }

            // initial test
            var lastSummary: TestResultSummary = try doTest(try: 0)

            // retries
            let maxTries = 5
            for retryNumber in 1..<maxTries where !lastSummary.runSucceeded {
                lastSummary = try retry(try: retryNumber, recordVideo: retryNumber == maxTries - 1)
            }

            if lastSummary.runSucceeded, lastSummary.try == 0 {
                banner("\u{1F389} All tests passed ON THE FIRST TRY! \u{1F389}")
            } else if lastSummary.runSucceeded {
                banner("All tests passed after \(lastSummary.try) retries!")
            } else {
                banner("\(lastSummary.failures.count) tests still failing after \(lastSummary.try) tries!")

                // export for blame bot
                try? cmd("envman", "add", "--key", "TESTS_FAILED", "--value", "yes").run()
                try cmd("echo", lastSummary.failures.joined(separator: "\n"))
                  .append(toFile: resultPath(for: "final-failed.txt"))
                  .run()
            }

            try mergeResults()

            if !lastSummary.runSucceeded {
                throw ExitCode.failure
            }
        }

        func doTest(try retryNumber: Int) throws -> TestResultSummary {
            let testRun = try baseTestRun.load()

            for configuration in testRun.TestConfigurations {
                var targets: [XCTestRun.TestTarget] = []
                let runName = "\(configuration.Name) (retry \(retryNumber))"
                configuration.Name = runName
                banner("Running \(runName)")

                for target in configuration.TestTargets {
                    guard let testNames = onlyTest[target.BlueprintName] else { continue }
                    targets.append(target)
                    target.SkipTestIdentifiers = (target.SkipTestIdentifiers ?? []) + (skipTest[target.BlueprintName] ?? [])
                    target.OnlyTestIdentifiers = testNames.isEmpty ? nil : testNames
                    if retryNumber > 0 {
                        target.EnvironmentVariables = target.EnvironmentVariables ?? [:]
                        target.EnvironmentVariables!["CANVAS_TEST_IS_RETRY"] = "YES"
                    }
                }
                configuration.TestTargets = targets
            }

            let testRunPath = "\(baseTestRun.buildDir)/tmp.xctestrun"
            try PropertyListEncoder().encode(testRun).write(to: URL(fileURLWithPath: testRunPath))
            let xcresult = resultPath(for: "\(retryNumber).xcresult")

            let success = Pipeline(
                xcodebuild(
                    noScheme: true,
                    "-resultBundlePath", xcresult,
                    "-xctestrun", testRunPath,
                    "test-without-building"
                ),
                cmd("tee", "-a", "\(deployDir)/testrun.log"),
                xcpretty()
            ).runBool()

            let summary = try TestResultSummary(try: retryNumber, xcresult: xcresult, runSucceeded: success)
            banner("\(summary.successes.count) tests passed, \(summary.failures.count) failed)")
            for test in summary.failures {
                print(" \u{274C} \(test)")
            }
            for test in summary.successes {
                let (suite, testName) = parse(testId: test)
                skipTest[suite] = skipTest[suite] ?? []
                skipTest[suite]!.append(testName)
            }

            return summary
        }

        struct TestResult: Codable {
            let status: String
            let id: String
        }

        struct TestResultSummary {
            let successes: [String]
            let failures: [String]
            let runSucceeded: Bool
            let `try`: Int

            init(try retryNumber: Int, xcresult: String, runSucceeded: Bool) throws {
                if !FileManager.default.fileExists(atPath: xcresult) {
                    try cmd("touch", resultPath(for: "final-failed.txt")).run()
                    try? cmd("envman", "add", "--key", "TESTS_FAILED", "--value", "yes").run()
                    throw InternalError(description: "Couldn't find test results!")
                }

                let testResultId = try (
                    cmd("xcrun", "xcresulttool", "get", "--format", "json", "--path", xcresult) |
                        cmd("jq", ".actions._values[].actionResult.testsRef.id._value")
                    ).runJSON(String.self)

                let allResults = try (
                    cmd("xcrun", "xcresulttool", "get",
                        "--format", "json",
                        "--path", xcresult,
                        "--id", testResultId
                        ) | cmd("jq", """
                              [.summaries._values[].testableSummaries._values[] |
                                .name._value as $bundleName |
                                .tests?._values[]? |
                                recurse(.subtests?._values[]?) |
                                select(._type._name == "ActionTestMetadata") |
                                ($bundleName + "/" + .identifier._value | rtrimstr("()")) as $testId |
                                {"status": .testStatus._value, "id": $testId}]
                              """
                    )
                    ).runJSON([TestResult].self)

                successes = allResults.compactMap { $0.status == "Success" ? $0.id : nil }
                failures = allResults.compactMap { $0.status == "Failure" ? $0.id : nil }
                self.runSucceeded = runSucceeded
                self.try = retryNumber
            }
        }

        func retry(`try` retryNumber: Int, recordVideo: Bool = false) throws -> TestResultSummary {
            var videoProcess: CommandResult?
            if recordVideo {
                let videoFile = "\(deployDir)/\(testRunId).mp4"
                print("recording video to \(videoFile)")
                videoProcess = cmd("xcrun", "simctl", "io", "booted", "recordVideo", videoFile).async()
            }
            defer {
                try? videoProcess?.kill()
                _ = videoProcess?.exitCode()
            }
            return try doTest(try: retryNumber)
        }

        func xcodebuild(noScheme: Bool = false, _ args: String...) -> Command {
            var flags: [String] = ["-destination", "platform=iOS Simulator,name=\(command.deviceName)"]
            if !noScheme {
                flags.append(contentsOf: [
                    "-workspace", "Canvas.xcworkspace",
                    "-scheme", command.scheme,
                ])
            }
            return cmd("xcodebuild", arguments: flags + args).output(overwritingFile: "/dev/null", fd: STDERR_FILENO)
        }

        func xcpretty(quiet: Bool = false) -> Command {
            cmd("tee", "-a", "\(deployDir)/build.log") |
              cmd("xcbeautify", arguments: quiet ? ["--quiet"] : [])
        }

        func mergeResults() throws {
            let mergedResultPath = resultPath(for: "merged.xcresult")
            try? cmd("mv", mergedResultPath, resultPath(for: "old-merged-\(testRunId).xcresult")).run()
            let xcresults = try FileManager.default.contentsOfDirectory(atPath: resultsDirectory)
              .filter { $0.hasSuffix(".xcresult") }
              .map { resultPath(for: $0) }
            if xcresults.count > 1 {
                try cmd("xcrun", arguments: ["xcresulttool", "merge"] + xcresults + ["--output-path", mergedResultPath]).run()
                try cmd("rm", arguments: ["-rf"] + xcresults).run()
            } else if let xcresult = xcresults.first {
                try cmd("mv", xcresult, mergedResultPath).run()
            }
        }
    }

    static func banner(_ message: String) {
        let termGreenBold = "\u{1b}[1m\u{1b}[32m"
        let termReset = "\u{1b}[m"

        print("\(termGreenBold)=\(String(repeating: "=", count: message.count))=\(termReset)")
        print("\(termGreenBold) \(message) \(termReset)")
        print("\(termGreenBold)=\(String(repeating: "=", count: message.count))=\(termReset)")
    }
}

extension Command {
    var silent: Command {
        self
          .output(overwritingFile: "/dev/null", fd: STDOUT_FILENO)
          .output(overwritingFile: "/dev/null", fd: STDERR_FILENO)
    }
}
