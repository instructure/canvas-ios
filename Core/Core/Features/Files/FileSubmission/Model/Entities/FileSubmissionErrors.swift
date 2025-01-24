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

public struct FileSubmissionErrors {
    public enum CoreData: Error, Equatable {
        case submissionNotFound
        case uploadItemNotFound
    }
    public enum UploadFinishedCheck: Error, Equatable {
        case notFinished
        case uploadFailed
        case coreData(CoreData)
    }
    public enum Submission: Error, Equatable {
        case submissionFailed
        case coreData(CoreData)
    }
    public enum UploadProgress: Error, Equatable {
        case uploadContinuedInApp
        case coreData(CoreData)
    }

    public struct RequestUploadTargetUnknownError: Error, Equatable {}
}

public extension Error {

    var shouldSendFailedNotification: Bool {
        (self as? FileSubmissionErrors.UploadFinishedCheck) == .uploadFailed ||
        (self as? FileSubmissionErrors.Submission) == .submissionFailed
    }
}
