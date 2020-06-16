//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import ReactiveSwift
import CanvasCore
import Core

fileprivate class EventRow: UIView {
    @objc let imageView = UIImageView()
    @objc let label = UILabel()
    
    init(icon: Icon) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView()
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        row.spacing = 8
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage.icon(icon)
        imageView.image = image
        row.addArrangedSubview(imageView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        row.addArrangedSubview(label)
        
        addSubview(row)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: image.size.width),
            imageView.heightAnchor.constraint(equalToConstant: image.size.height),
            
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("N/A")
    }
}

class CalendarEventDetailViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let locationNameLabel = UILabel()
    private let locationAddressLabel = UILabel()
    private let courseRow = EventRow(icon: .course)
    private let dateRow = EventRow(icon: .calendar)
    private var details = CanvasWebView()
    private var detailsHeightConstraint: NSLayoutConstraint?
    
    private let observer: ManagedObjectObserver<CalendarEvent>
    private let refresher: Refresher
    private let enrollments: EnrollmentsDataSource
    
    private let intervalFormatter = DateIntervalFormatter()
    private let instantFormatter: DateFormatter = {
        let f = DateFormatter()
        return f
    }()
    private let allDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
    
    @objc let route: (UIViewController, URL) -> Void
    
    @objc init(forEventWithID eventID: String, in session: Session, route: @escaping (UIViewController, URL) -> Void) throws {
        self.observer = try CalendarEvent.observer(session, calendarEventID: eventID)
        self.refresher = try CalendarEvent.refresher(session, calendarEventID: eventID)
        self.enrollments = session.enrollmentsDataSource
        self.route = route
        
        super.init(nibName: nil, bundle: nil)

        observer.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] _, event in
                guard let me = self else {
                    return
                }
                me.update(for: event)
        }
        
        update(for: observer.object)
        navigationItem.title = NSLocalizedString("Calendar Event", comment: "")
    }
    
    private func update(for event: CalendarEvent?) {
        titleLabel.text = event?.title
        let enrollment: CanvasCore.Enrollment? = (event?.contextCode)
            .flatMap { Context(canvasContextID: $0) }
            .flatMap { enrollments[$0] }
        
        courseRow.isHidden = enrollment == nil
        courseRow.label.text = enrollment?.name
        view.tintColor = enrollment?.color.value ?? .prettyGray()
        switch (event?.startAt, event?.endAt, event?.allDay) {
        case let (.some(start), _, .some(true)):
            dateRow.label.text = allDayFormatter.string(from: start)
        case let (.some(start), .some(end), _):
            dateRow.label.text = intervalFormatter.string(from: start, to: end)
        case let (.some(start), _, _):
            dateRow.label.text = instantFormatter.string(from: start)
        default:
            dateRow.label.text = "--"
        }

        locationNameLabel.text = event?.locationName
        locationAddressLabel.text = event?.locationAddress
        
        if let description = event?.htmlDescription {
            details.load(html: description, title: nil, baseURL: nil) { [weak self] url in
                guard let me = self else { return }
                me.route(me, url)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresher.refresh(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        details.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(details)
        scrollView.bottomAnchor.constraint(equalTo: details.bottomAnchor).isActive = true

        details.topAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
        details.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: -16).isActive = true
        details.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 16).isActive = true
        detailsHeightConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[view(0)]", options: [], metrics: nil, views: ["view": self.details]).first
        if let detailsHeightConstraint = detailsHeightConstraint {
            details.addConstraint(detailsHeightConstraint)
        }
        
        details.finishedLoading = { [weak self] in
            self?.details.htmlContentHeight() { height in
                self?.detailsHeightConstraint?.constant = height
            }
        }
    }

    override func loadView() {
        scrollView.backgroundColor = .white
        self.view = scrollView
        
        refresher.makeRefreshable(self)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 32)
        titleLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(courseRow)
        stack.addArrangedSubview(dateRow)

        locationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        locationNameLabel.numberOfLines = 0

        locationAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        locationAddressLabel.numberOfLines = 0

        stack.addArrangedSubview(locationNameLabel)
        stack.addArrangedSubview(locationAddressLabel)

        scrollView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            scrollView.readableContentGuide.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            scrollView.readableContentGuide.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: stack.topAnchor),
        ])
    }
}
