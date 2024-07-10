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

struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    let textViewBuilder: () -> UITextView

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let tv = textViewBuilder()
        tv.delegate = context.coordinator
        return tv
    }

    func updateUIView(_ textView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        textView.text = text
    }

    func makeCoordinator() -> Coordinator {
      let coordinator = Coordinator(self)

      return coordinator
    }

    class Coordinator: NSObject, UITextViewDelegate {

      var parent: UITextViewWrapper

      init(_ textField: UITextViewWrapper) {
        self.parent = textField
      }

      func textViewDidChange(_ textView: UITextView) {
        self.parent.text = textView.text
      }
    }
}
