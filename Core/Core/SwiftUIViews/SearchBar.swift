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

import UIKit
import SwiftUI

public struct SearchBar: UIViewRepresentable {
    let onCancel: () -> Void
    let placeholder: String
    @Binding var text: String

    public init(text: Binding<String>, placeholder: String, onCancel: @escaping () -> Void = {}) {
        self.onCancel = onCancel
        self.placeholder = placeholder
        self._text = text
    }

    public func makeUIView(context: Self.Context) -> UISearchBar { UISearchBar() }

    public func updateUIView(_ uiView: UISearchBar, context: Self.Context) {
        uiView.barTintColor = .backgroundLightest
        uiView.delegate = context.coordinator
        uiView.placeholder = placeholder
        uiView.text = text
    }

    public func makeCoordinator() -> Coordinator { Coordinator(view: self) }

    public class Coordinator: NSObject, UISearchBarDelegate {
        let view: SearchBar

        init(view: SearchBar) {
            self.view = view
        }

        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            view.text = searchText
        }

        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }

        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }

        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            self.searchBar(searchBar, textDidChange: "")
            searchBar.endEditing(true)
            view.onCancel()
        }
    }
}
