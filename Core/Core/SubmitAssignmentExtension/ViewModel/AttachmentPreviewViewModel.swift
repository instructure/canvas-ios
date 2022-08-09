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

import Combine
import SwiftUI

class AttachmentPreviewViewModel: ObservableObject {
    enum State {
        case loading
        case noPreview
        case media(image: UIImage, length: String?)
        case pdf(fileName: String)
    }
    private static let videoLengthFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    @Published public private(set) var state: State = .loading
    private let filePreviewProvider: FilePreviewProvider
    private var subscriptions = Set<AnyCancellable>()

    public init(url: URL) {
        filePreviewProvider = FilePreviewProvider(url: url)
        filePreviewProvider.result
            .map { result -> State in
                switch result {
                case .pdf(let fileName): return .pdf(fileName: fileName)
                case .image(let image): return .media(image: image, length: nil)
                case .movie(let image, let duration): return .media(image: image, length: Self.videoLengthFormatter.string(from: duration))
                case .unknown: return .noPreview
                case .none: return .loading
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.state = state }
            .store(in: &subscriptions)
    }
}
