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

struct ExportCoverage: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Export xccov information to a format codecov.io can parse"
    )

    struct CoverageLine: Encodable {
        let hits: Int
        let fragments: [String: Fragment]

        struct Fragment {
            let start: Int
            let length: Int
            let hits: Int

            init(start: Int, length: Int, hits: Int) {
                self.start = start
                self.length = length
                self.hits = hits
            }

            init?(fromArchive string: String) {
                let components = (string.split { "(), ".contains($0) })
                guard components != ["]"] else { return nil }
                (start, length, hits) = (components.map { Int($0)! }).tup3!
            }

            func merging(_ other: Fragment) -> Fragment {
                assert(start == other.start)
                assert(length == other.length)
                return Fragment(start: start, length: length, hits: hits + other.hits)
            }
        }

        func merging(_ other: CoverageLine) -> CoverageLine {
            CoverageLine(
                hits: hits + other.hits,
                fragments: fragments.merging(other.fragments) { $0.merging($1) }
            )
        }

        func encode(to encoder: Encoder) throws {
            if fragments.isEmpty {
                try hits.encode(to: encoder)
            } else {
                let cases = [hits] + fragments.values.map { $0.hits }
                let hit = cases.filter { $0 > 0 }
                try "\(hit.count)/\(cases.count)".encode(to: encoder)
            }
        }
    }

    func run() throws {
        let archiveIds = try (
            cmd("xcrun", "xcresulttool", "--legacy", "get", "--path", "scripts/coverage/citests.xcresult", "--format", "json") |
                cmd("jq", "[.actions._values[].actionResult.coverage.archiveRef.id._value]")
            ).runJSON([String?].self)

        var archivePaths: [String] = []
        for (index, id) in archiveIds.enumerated() {
            guard let id = id else {
                continue
            }
            let archivePath = "tmp/cov-\(index).xccovarchive"
            archivePaths.append(archivePath)
            try cmd(
                "xcrun", "xcresulttool", "export",
                "--path", "scripts/coverage/citests.xcresult",
                "--output-path", archivePath,
                "--type", "directory",
                "--id", id
            ).run()
        }

        struct CodecovReport: Encodable {
            var coverage = [String: [Int: CoverageLine]]()

            mutating func add(_ file: String, _ line: Int, _ lineCoverage: CoverageLine) {
                coverage.merge([file: [line: lineCoverage]]) { lines0, lines1 in
                    return lines0.merging(lines1) { line0, line1 in
                        line0.merging(line1)
                    }
                }
            }
        }

        var report = CodecovReport()

        for archivePath in archivePaths {
            let files = try cmd("xcrun", "xccov", "view", archivePath, "--file-list").runLines()
            for file in files {
                let lines = try cmd("xcrun", "xccov", "view", archivePath, "--file", file).runLines()
                var queue: [String] = lines.reversed()
                while !queue.isEmpty {
                    let components = queue.removeLast().split { " :".contains($0) }
                    let (line, hits) = components.tup2!
                    guard hits != "*" else { continue }
                    var fragments = [String: CoverageLine.Fragment]()
                    if components[safe: 2] == "[" {
                        while let fragment = CoverageLine.Fragment(fromArchive: queue.removeLast()) {
                            fragments["\(fragment.start)-\(fragment.length)"] = fragment
                        }
                    }
                    report.add(file, Int(line)!, CoverageLine(hits: Int(hits)!, fragments: fragments))
                }
            }
        }

        try cmd("jq").inputJSON(from: report).output(overwritingFile: "scripts/coverage/xccov.json").run()
    }
}
