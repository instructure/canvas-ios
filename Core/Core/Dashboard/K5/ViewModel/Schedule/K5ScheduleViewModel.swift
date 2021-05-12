//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5ScheduleViewModel: ObservableObject {
    @Published var content: String = "Binding test"
    private var timer: Timer!

    init() {
        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.content.append(".")
        }
        RunLoop.main.add(timer, forMode: .default)
    }

    deinit {
        timer.invalidate()
    }
}

extension K5ScheduleViewModel: Refreshable {

    func refresh(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.content = "Binding test"
            completion()
        }
    }
}
