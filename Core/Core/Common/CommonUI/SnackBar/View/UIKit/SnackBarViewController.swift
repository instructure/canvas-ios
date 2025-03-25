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

import SwiftUI

public class SnackBarViewController: CoreHostingController<SnackWrapper> {

    public init(viewModel: SnackBarViewModel) {
        super.init(SnackWrapper(viewModel: viewModel))
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct SnackWrapper: View {
    @ObservedObject var viewModel: SnackBarViewModel

    init(viewModel: SnackBarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Color.clear.snackBar(viewModel: viewModel)
    }
}
