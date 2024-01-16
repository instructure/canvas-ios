//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI

struct AudioPickerViewController: UIViewControllerRepresentable {

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<AudioPickerViewController>) -> AudioRecorderViewController {

            let audioRecorder = AudioRecorderViewController.create()
            audioRecorder.delegate = makeCoordinator()
            audioRecorder.view.backgroundColor = .backgroundLightest
            audioRecorder.modalPresentationStyle = .formSheet

            return audioRecorder
    }

    func updateUIViewController(_ uiViewController: AudioRecorderViewController, context: UIViewControllerRepresentableContext<AudioPickerViewController>) {

    }

    final class Coordinator: NSObject, AudioRecorderDelegate {
        func cancel(_ controller: AudioRecorderViewController) {

        }
        
        func send(_ controller: AudioRecorderViewController, url: URL) {
            
        }
        
    }
}

