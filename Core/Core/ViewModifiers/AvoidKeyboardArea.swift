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
import Combine

struct AvoidKeyboardArea<Content: View>: View {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification).map { notification in
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
        }
        let willChange = NotificationCenter.default.publisher(for: UIApplication.keyboardWillChangeFrameNotification).map { notification in
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
        }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification).map { _ in
            CGFloat(0)
        }
        let willResignActive = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).map { _ in
            CGFloat(0)
        }

        return Publishers.MergeMany(willShow, willChange, willHide, willResignActive).eraseToAnyPublisher()
    }

    let content: Content
    @State var padding: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.padding)
                .onReceive(AvoidKeyboardArea.keyboardHeight) { height in
                    let maxY = geometry.frame(in: .global).maxY
                    let distanceToBottom = UIScreen.main.bounds.height - maxY
                    // The keyboard uses a private UIView.AnimationCurve type, but the spring animation matches it quite well.
                    withAnimation(.spring()) {
                        self.padding = max(0, height - distanceToBottom - geometry.safeAreaInsets.bottom)
                    }
                }
        }
    }
}

extension View {

    /**
     This method adds a view modifier which pushes content up by modifying its bottom padding in case a keyboard appears.
     Usually, this behavior is automatically achieved by SwiftUI but if not this modifier can be used to achieve a similar effect.
     */
    @ViewBuilder
    public func avoidKeyboardArea() -> some View {
        AvoidKeyboardArea(content: self)
    }
}
