//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension FileSubmission {

    public enum State: Equatable {
        case waiting
        case uploading(progress: CGFloat)
        /** One of the files failed to upload. */
        case failedUpload
        /** Files are successfully uploaded but the submission of those files to the assignment failed. */
        case failedSubmission(message: String)
        case submitted

        /**
         This initializer maps item states to submission state.
         States `failedSubmission` and `submitted` are not valid results of this initializer because these states
         are the results of the submission API call and that happens after file uploads were successful.
         */
        public init(_ itemStates: [FileSubmissionItem.State]) {
            if itemStates.finishedCount == itemStates.count {
                if itemStates.failedCount == 0 {
                    self = .uploading(progress: 1)
                } else {
                    self = .failedUpload
                }
            } else if itemStates.containsUploading {
                self = .uploading(progress: itemStates.progressSum / CGFloat(itemStates.count))
            } else {
                self = .waiting
            }
        }
    }
}

private extension Array where Element == FileSubmissionItem.State {

    var finishedCount: Int {
        reduce(into: 0) { result, state in
            switch state {
            case .uploaded, .error:
                result += 1
            default:
                break
            }
        }
    }
    var failedCount: Int {
        reduce(into: 0) { result, state in
            if case .error = state {
                result += 1
            }
        }
    }
    var containsUploading: Bool {
        contains { state in
            if case .uploading = state {
                return true
            } else {
                return false
            }
        }
    }
    var progressSum: CGFloat {
        reduce(into: CGFloat(0)) { result, state in
            switch state {
            case .uploading(let progress):
                result += progress
            case .waiting:
                break
            default:
                result += 1
            }
        }
    }
}
