//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SoSeedySwift

extension TeacherTest {

    enum submissionGraphTitleLabel: String {
        case graded = "Graded"
        case ungraded = "Ungraded"
        case notSubmitted = "Not Submitted"
    }

    enum dateTitleLabel: String {
        case availableFrom = "Available from:"
        case availableTo = "Available to:"
    }

    func submissionTypesFormattedString(_ submissionTypes: [SubmissionType]) -> [String] {
        return submissionTypes.map { $0.rawValue }.map({
            (submissionType : String) -> String in
            return submissionType.replacingOccurrences(
                of: "_",
                with: " ").capitalized.replacingOccurrences(
                    of: "Url",
                    with: "URL")
        })
    }

    func publishStatusFormattedString(_ published: Bool) -> String {
        return (published) ? "Published" : "Unpublished"
    }

    func emptyDateFormatttedString(for titleLabel: dateTitleLabel) -> String {
        return titleLabel.rawValue + " --"
    }
}
