//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public protocol PagingViewController: UIViewController {
    associatedtype Page: PageModel

    func isMoreRow(at indexPath: IndexPath) -> Bool
    func loadNextPage()
}

public protocol PageModel {
    var nextCursor: String? { get }
}

public class Paging<Controller: PagingViewController> {

    private var endCursor: String?
    private var isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private var loadedCursor: String?
    private unowned let controller: Controller

    public init(controller: Controller) {
        self.controller = controller
    }

    public var hasMore: Bool { endCursor != nil }

    public func onPageLoaded(_ page: Controller.Page) {
        endCursor = page.nextCursor
        isLoadingMoreSubject.send(false)
    }

    public func onPageLoadingFailed() {
        isLoadingMoreSubject.send(false)
    }

    public func willDisplayRow(at indexPath: IndexPath) {
        guard controller.isMoreRow(at: indexPath), isLoadingMoreSubject.value == false else { return }
        guard let endCursor, endCursor != loadedCursor else { return }
        loadMore()
    }

    public func willSelectRow(at indexPath: IndexPath) {
        guard controller.isMoreRow(at: indexPath), isLoadingMoreSubject.value == false else { return }
        loadMore()
    }

    private func loadMore() {
        guard let endCursor else { return }

        loadedCursor = endCursor
        isLoadingMoreSubject.send(true)

        controller.loadNextPage()
    }

    public func setup(in cell: PageLoadingCell) -> PageLoadingCell {
        cell.observeLoading(isLoadingMoreSubject.eraseToAnyPublisher())
        return cell
    }
}

public class PageLoadingCell: UITableViewCell {
    required init?(coder: NSCoder) { nil }

    private let progressView = CircleProgressView()
    private let label = UILabel()

    private var subscriptions = Set<AnyCancellable>()

    override public func layoutSubviews() {
        super.layoutSubviews()

        subviews.forEach { subview in
            guard subview != contentView else { return }
            subview.isHidden = true
        }
    }

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(progressView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 32),
            progressView.heightAnchor.constraint(equalToConstant: 32),
            progressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        contentView.addSubview(label)

        label.text = String(localized: "Load More", bundle: .core)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
    }

    fileprivate func observeLoading(_ loadingPublisher: AnyPublisher<Bool, Never>) {
        loadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.setupAsProgressView()
                } else {
                    self?.setupAsButton()
                }
            }
            .store(in: &subscriptions)
    }

    private func setupAsButton() {
        backgroundConfiguration = nil
        progressView.isHidden = true
        label.isHidden = false
    }

    private func setupAsProgressView() {
        backgroundConfiguration = UIBackgroundConfiguration.clear()
        progressView.isHidden = false
        label.isHidden = true
    }
}
