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

import SwiftUI

public struct AudioRecorder: UIViewControllerRepresentable {
    public let action: (URL?) -> Void

    public init(action: @escaping (URL?) -> Void) {
        self.action = action
    }

    public func makeUIViewController(context: Self.Context) -> AudioRecorderViewController {
        return AudioRecorderViewController.create()
    }

    public func updateUIViewController(_ uiViewController: AudioRecorderViewController, context: Self.Context) {
        uiViewController.delegate = context.coordinator
    }

    public class Coordinator: AudioRecorderDelegate {
        let view: AudioRecorder

        init(view: AudioRecorder) {
            self.view = view
        }

        public func cancel(_ controller: AudioRecorderViewController) {
            view.action(nil)
        }

        public func send(_ controller: AudioRecorderViewController, url: URL) {
            view.action(url)
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(view: self)
    }

    public static func requestPermission(callback: @escaping (Bool) -> Void) {
        AudioRecorderViewController.requestPermission(callback: callback)
    }
}
