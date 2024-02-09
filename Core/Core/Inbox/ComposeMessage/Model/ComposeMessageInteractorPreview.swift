//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

#if DEBUG

import Combine
import CombineExt

public class ComposeMessageInteractorPreview: ComposeMessageInteractor {

    public func createConversation(parameters: MessageParameters) -> Future<URLResponse?, Error> {
        Future<URLResponse?, Error> { promise in
            promise(.success(nil))
        }
    }

    public func addConversationMessage(parameters: MessageParameters) -> Future<URLResponse?, Error> {
        Future<URLResponse?, Error> { promise in
            promise(.success(nil))
        }
    }
}

#endif
