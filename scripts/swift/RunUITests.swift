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

private let maxTries = 5

struct RunUITests: ParsableCommand {
    @Option()
    var scheme: String = "NightlyTests"

    @Option()
    var deviceName: String = "iPhone SE (3rd generation)"

    @Flag(help: "build test target first")
    var build: Bool = false

    @Flag(help: "append to ui-test-results instead of clobbering it")
    var appendResults: Bool = false

    @Flag(help: "run all tests in scheme")
    var allTests: Bool = false

    @Flag(help: "Show all log")
    var verbose: Bool = false

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
}

private class Runner {
    let command: RunUITests

    var skipTest: [String: [String]] = [:]
    var onlyTest: [String: [String]] = [:]
    var baseTestRun: BaseTestRun!

    init(_ command: RunUITests) {
        self.command = command
    }

    func run() throws {
        try setUp()
        baseTestRun = try getBaseTestRun(build: command.build)
        onlyTest = try enabledTests()

        if onlyTest.isEmpty {
            print("No tests requested")
            return
        }

        // first try
        var lastSummary = try doTest(try: 0)

        // retries
        for retryNumber in 1..<maxTries where !lastSummary.runSucceeded {
            let lastTry = retryNumber == maxTries - 1
            lastSummary = try retry(try: retryNumber, recordVideo: lastTry)
        }

        if lastSummary.runSucceeded, lastSummary.try == 0 {
            banner("\u{1F389} All tests passed ON THE FIRST TRY! \u{1F389}")
        } else if lastSummary.runSucceeded {
            banner("All tests passed after \(lastSummary.try) retries!")
        } else {
            banner("\(lastSummary.failures.count) tests still failing after \(lastSummary.try) tries!")

            // export for blame bot
            try? cmd("envman", "add", "--key", "TESTS_FAILED", "--value", "yes").silent.run()
            try cmd("echo", lastSummary.failures.joined(separator: "\n"))
              .append(toFile: resultPath(for: "final-failed.txt"))
              .run()
        }

        try mergeResults()

        if !lastSummary.runSucceeded {
            throw ExitCode.failure
        }
    }

    func setUp() throws {
        ExternalCommand.verbose = command.verbose
        // Launch the sim first to save time later
        try cmd("open", "-a", cmd("xcode-select", "-p").runString() + "/Applications/Simulator.app").run()
        sleep(3)

        if let booted = try? (cmd("xcrun", "simctl", "list") | cmd("grep", "Booted")).runString(),
           !booted.trimmingCharacters(in: .whitespaces).hasPrefix(command.deviceName) {
            try? cmd("xcrun", "simctl", "shutdown", "booted").run()
        }
        try? cmd("xcrun", "simctl", "boot", command.deviceName).run()

        Darwin.setenv("NSUnbufferedIO", "YES", 1)
        try cmd("mkdir", "-p", "tmp").run()
        try cmd("touch", "tmp/timestamp").run()

        if !command.appendResults {
            try cmd("rm", "-rf", resultsDirectory).run()
        }
        try cmd("mkdir", "-p", resultsDirectory).run()
    }

    func getBaseTestRun(build: Bool) throws -> BaseTestRun {
        if build {
            banner("Building \(command.scheme)")
            try (xcodebuild("build-for-testing") | xcpretty(quiet: true)).run()
        }

        let buildDir = try (
          xcodebuild("-showBuildSettings", "build-for-testing", "-json") |
            cmd("jq", ".[0].buildSettings.BUILD_DIR")
        ).runJSON(String.self)

        let builtTestRuns = try FileManager.default.contentsOfDirectory(atPath: buildDir).filter {
            $0.hasPrefix(command.scheme) &&
              $0.range(of: #"_.*_iphonesimulator.*\.xctestrun$"#, options: .regularExpression) != nil
        }
        if builtTestRuns.count < 1 {
            throw InternalError(description: "couldn't find xctestrun product (possible fix: add the --build flag)")
        } else if builtTestRuns.count > 1 {
            throw InternalError(description: "couldn't determine unique xctestrun product. try cleaning")
        }
        return BaseTestRun(buildDir: buildDir, testRun: builtTestRuns[0])
    }

    func enabledTests() throws -> [String: [String]] {
        var tests: [String: [String]] = [:]
        if command.allTests {
            for configuration in try baseTestRun.load().TestConfigurations {
                for target in configuration.TestTargets {
                    tests[target.BlueprintName] = target.OnlyTestIdentifiers ?? []
                }
            }
        } else {
            for test in command.tests {
                let (suite, testName) = parse(testId: test)
                tests[suite] = tests[suite] ?? []
                if !testName.isEmpty {
                    tests[suite]!.append(testName)
                }
            }
        }
        return tests
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

    func retry(`try` retryNumber: Int, recordVideo: Bool = false) throws -> TestResultSummary {
        var videoProcess: CommandResult?
        if recordVideo {
            let videoFile = "\(deployDir)/\(testRunId).mp4"
            print("recording video to \(videoFile)")
            videoProcess = cmd("xcrun", "simctl", "io", "booted", "recordVideo", videoFile).async()
        }
        defer {
            try? videoProcess?.kill(signal: SIGINT)
            _ = videoProcess?.exitCode()
        }
        return try doTest(try: retryNumber)
    }

    struct TestResultSummary {
        let successes: [String]
        let failures: [String]
        let runSucceeded: Bool
        let `try`: Int

        init(try retryNumber: Int, xcresult: String, runSucceeded: Bool) throws {
            if !FileManager.default.fileExists(atPath: xcresult) {
                try cmd("touch", resultPath(for: "final-failed.txt")).run()
                try? cmd("envman", "add", "--key", "TESTS_FAILED", "--value", "yes").silent.run()
                throw InternalError(description: "Couldn't find test results!")
            }

            let testResultId = try (
              cmd("xcrun", "xcresulttool", "get", "--format", "json", "--path", xcresult) |
                cmd("jq", ".actions._values[].actionResult.testsRef.id._value")
            ).runJSON(String.self)

            struct TestResult: Codable {
                let status: String
                let id: String
            }
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

    func xcodebuild(noScheme: Bool = false, _ args: String...) -> Command {
        var flags: [String] = [
          "-destination", "platform=iOS Simulator,name=\(command.deviceName)",
          "COMPILER_INDEX_STORE_ENABLE=NO",
        ]
        if !noScheme {
            flags.append(contentsOf: [
                           "-workspace", "Canvas.xcworkspace",
                           "-scheme", command.scheme,
                         ])
        }
        return cmd("xcodebuild", arguments: flags + args).output(overwritingFile: "/dev/null", fd: FileDescriptor(rawValue: STDERR_FILENO))
    }

    func xcpretty(quiet: Bool = false) -> Command {
        cmd("tee", "-a", "\(deployDir)/build.log") |
          cmd("xcbeautify", arguments: !command.verbose && quiet ? ["--quiet"] : [])
    }

    func mergeResults() throws {
        let mergedResultPath = resultPath(for: "merged.xcresult")
        try? cmd("mv", mergedResultPath, resultPath(for: "old-merged-\(testRunId).xcresult")).silent.run()
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

private struct InternalError: Error, CustomStringConvertible {
    var description: String
}

private let testRunId = UUID()
private var deployDir: String { Env.env["BITRISE_DEPLOY_DIR"] ?? resultsDirectory }

private let resultsDirectory = "ui-test-results"
private func resultPath(for name: String) -> String {
    "\(resultsDirectory)/\(name)"
}

private struct BaseTestRun: Codable {
    let buildDir: String
    let testRun: String

    func load() throws -> XCTestRun {
        let data = try Data(contentsOf: URL(fileURLWithPath: "\(buildDir)/\(testRun)"))
        return try PropertyListDecoder().decode(XCTestRun.self, from: data)
    }
}

private func parse(testId: String) -> (String, String) {
    let parts = testId.split(separator: "/")
    return (String(parts[0]), parts.dropFirst().joined(separator: "/"))
}

private func banner(_ message: String) {
    let termGreenBold = "\u{1b}[1m\u{1b}[32m"
    let termReset = "\u{1b}[m"

    print("\(termGreenBold)=\(String(repeating: "=", count: message.count))=\(termReset)")
    print("\(termGreenBold) \(message) \(termReset)")
    print("\(termGreenBold)=\(String(repeating: "=", count: message.count))=\(termReset)")
}

extension Command {
    var silent: Command {
        self
          .output(overwritingFile: "/dev/null", fd: FileDescriptor(rawValue: STDOUT_FILENO))
          .output(overwritingFile: "/dev/null", fd: FileDescriptor(rawValue: STDERR_FILENO))
    }
}
