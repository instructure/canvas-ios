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

public class AttachmentPreviewViewModel: ObservableObject {
    public enum State: Equatable {
        case loading
        case noPreview
        case media(image: UIImage, length: String?)
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

    public init(previewProvider: FilePreviewProvider) {
        filePreviewProvider = previewProvider
        subscribeToPreviewData()
        filePreviewProvider.load()
    }

    private func subscribeToPreviewData() {
        filePreviewProvider.result
            .map { previewData -> State in
                let durationString: String? = {
                    guard let duration = previewData.duration else { return nil }
                    return Self.videoLengthFormatter.string(from: duration)
                }()
                return .media(image: previewData.image, length: durationString)
            }
            .replaceError(with: .noPreview)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
}

extension AttachmentPreviewViewModel: Identifiable {
    public var id: URL { filePreviewProvider.url }
}
