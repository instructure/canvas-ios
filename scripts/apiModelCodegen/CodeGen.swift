#!/usr/bin/swift -F Carthage/Build/Mac/
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
import Mustache

struct Input: Codable {
    let entity: String
    let properties: [[String: String]]

    func toDictionary() -> [String: Any] {
        return ["entity": entity, "properties": properties]
    }
}

enum TemplateType: String {
    case APIModel, APIModelFixture, GetApiRequestable, GetApiRequestableTests, GetUseCase, GetUseCaseTests

    var fullpath: String {
        return "templates/\(self.rawValue).mustache"
    }

    func filename(_ params: Input) -> String {
        switch self {
        case .APIModel: return "API\(params.entity)"
        case .APIModelFixture: return "API\(params.entity)Fixture"
        case .GetApiRequestable: return "Get\(params.entity)Requestable"
        case .GetApiRequestableTests: return "Get\(params.entity)RequestableTests"
        case .GetUseCase: return "Get\(params.entity)UseCase"
        case .GetUseCaseTests: return "Get\(params.entity)UseCaseTests"
        }
    }
}

func writeTemplateToFile(_ templateType: TemplateType, params: Input) {
    do {
        let mustacheTemplate = try Template(path: templateType.fullpath)
        let output = try mustacheTemplate.render(params.toDictionary())
        let outputDir = "./output"
        var url = URL(fileURLWithPath: outputDir, isDirectory: true)

        url.appendPathComponent("\(templateType.filename(params)).swift")
        try output.write(to: url, atomically: true, encoding: .utf8)
    }
    catch let error as MustacheError {
        print("[mustache error]: \(error)")
    }
    catch {
        print("[error]: \(error)")
    }
}

do {
    let inputFile = URL(fileURLWithPath: "./input.json", isDirectory: false)
    let data = try Data(contentsOf: inputFile)
    let decoder = JSONDecoder()
    let input: Input = try decoder.decode(Input.self, from: data)

    writeTemplateToFile(.APIModel, params: input)
    writeTemplateToFile(.APIModelFixture, params: input)
    writeTemplateToFile(.GetApiRequestable, params: input)
    writeTemplateToFile(.GetApiRequestableTests, params: input)
    writeTemplateToFile(.GetUseCase, params: input)
    writeTemplateToFile(.GetUseCaseTests, params: input)
}
catch {
    print("[I/O error]: \(error)")
    exit(EXIT_FAILURE);
}
