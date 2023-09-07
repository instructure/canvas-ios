//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Combine
import mobile_offline_downloader_ios

public class NotConnectionBarView: UIView, Reachabilitable {

    @Injected(\.reachability) var reachability: ReachabilityProvider
    var cancellables: [AnyCancellable] = []

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.text = "No Internet Connection"
        return titleLabel
    }()

    public convenience init() {
        self.init(frame: .zero)
        isHidden = false
        addObservers()
    }

    private func addObservers() {
        if reachability.notifierRunning {
            isHidden = reachability.isConnected
        }

        connection { [weak self] isConnected in
            self?.isHidden = isConnected
            if isConnected {
                OfflineDownloadsManager.shared.resumeAllActive()
            } else {
                OfflineDownloadsManager.shared.pauseAllActive()
            }
        }
    }

    private func attachLabel() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    public func attach(tabBar: UITabBar, in superview: UIView) {
        backgroundColor = .red

        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 20).isActive = true

        attachLabel()
    }
}
