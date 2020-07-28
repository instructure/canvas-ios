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

import Combine

@available(iOSApplicationExtension 13.0, *)
public class PublishObserver<ViewModel>: ObservableObject {
    @Published public var model: ViewModel
    private var cancel: AnyCancellable?

    public init<P: Publisher>(publisher: P, initialModel: ViewModel) where P.Output == ViewModel, P.Failure == Never {
        model = initialModel
        cancel = publisher.assign(to: \.model, on: self)
    }

    public init(staticContents: ViewModel) {
        model = staticContents
    }
}
