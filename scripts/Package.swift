// swift-tools-version:5.2
//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import PackageDescription

let package = Package(
    name: "scripts",
    platforms: [ .macOS(.v10_15) ],
    products: [
        .executable(name: "scripts-main", targets: [ "scripts" ]),
    ],
    dependencies: [
        .package(url: "https://github.com/cobbal/swsh.git", .exact("3.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("1.0.1")),
        .package(url: "https://github.com/davidahouse/XCResultKit", .exact("1.2.1")),
        .package(url: "https://github.com/cobbal/GitDiffSwift.git", .exact("0.0.2")),
    ],
    targets: [
        .target(
            name: "scripts",
            dependencies: [
                "swsh",
                "XCResultKit",
                "GitDiffSwift",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "swift"
        ),
    ]
)
