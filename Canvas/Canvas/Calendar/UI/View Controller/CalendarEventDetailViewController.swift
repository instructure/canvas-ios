//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CanvasCore
import ReactiveSwift

fileprivate class EventRow: UIView {
    let imageView = UIImageView()
    let label = UILabel()
    
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
    
    let route: (UIViewController, URL) -> Void
    
    init(forEventWithID eventID: String, in session: Session, route: @escaping (UIViewController, URL) -> Void) throws {
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
        let enrollment: Enrollment? = (event?.contextCode)
            .flatMap { ContextID(canvasContext: $0) }
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
        
        if let description = event?.htmlDescription {
            details.load(html: description, title: event?.title, baseURL: nil) { [weak self] url in
                guard let me = self else { return }
                me.route(me, url)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        details.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(details)
        scrollView.bottomAnchor.constraint(equalTo: details.bottomAnchor).isActive = true

        details.topAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
        details.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        details.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
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
        let spacing = CGFloat(16)
        
        scrollView.backgroundColor = .white
        self.view = scrollView
        
        refresher.makeRefreshable(self)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 32)
        titleLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(courseRow)
        stack.addArrangedSubview(dateRow)
        
        scrollView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            scrollView.readableContentGuide.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            scrollView.readableContentGuide.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: stack.topAnchor, constant: -spacing),
        ])
    }
}
