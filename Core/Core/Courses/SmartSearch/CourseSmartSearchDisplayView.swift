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

public struct CourseSmartSearchDisplayView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.searchContext) private var searchContext

    @Binding public var phase: SearchPhase
    @Binding public var filters: FiltersState

    @State var results: [SearchResult] = []

    public init(phase: Binding<SearchPhase>, filters: Binding<FiltersState>) {
        self._phase = phase
        self._filters = filters
    }

    public var body: some View {
        ZStack {
            switch phase {
            case .loading, .start:
                SearchLoadingView()
            case .noMatch:
                SearchNoMatchView()
            case .results:
                CourseSmarSearchResultsView(results: $results)
            case .filteredResults:
                CourseSmartSearchFilteredResultsView(resultSections: sectionedResults)
            }
        }
        .ignoresSafeArea()
        .background(Color.backgroundLight)
        .sheet(isPresented: $filters.isPresented, content: {
            SmartSearchFiltersView()
        })
        .onAppear {
            guard case .start = phase else { return }
            startLoading()
        }
        .onReceive(searchContext.didSubmit, perform: { newTerm in
            startLoading(with: newTerm)
        })
    }

    var sectionedResults: [SearchResultsSection] {
        var list = Dictionary(grouping: results, by: { $0.content_type })
            .map({ SearchResultsSection(type: $0, results: $1) })
            .sorted(by: { $0.type.sortOrder < $1.type.sortOrder})

        if var first = list.first {
            first.expanded = true
            list[0] = first
        }

        return list
    }

    func startLoading(with term: String? = nil) {
        let searchTerm = term ?? searchContext.searchTerm.value
        phase = .loading

        print("Searching `\(searchTerm)` ..")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // TODO: Fetch results through API
            results = SearchResult.simpleExample.sorted(by: { $0.distanceDots > $1.distanceDots })
            phase = .results
            //filters.isActive = true
        }
    }
}

#Preview {
    CourseSmartSearchDisplayView(
        phase: .constant(.results),
        filters: .constant(.empty)
    )
}

struct CourseSmarSearchResultsView: View {

    @Binding var results: [SearchResult]

    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack(spacing: 0) {
                    SearchResultsHeaderView()
                        .anchorPreference(
                            key: OffsetKey.self,
                            value: .top,
                            transform: { anchor in
                                return g[anchor].y
                            })
                    LazyVStack {
                        ForEach(results) { result in
                            let last = results.last?.id == result.id
                            SearchResultRow(result: result, last: last)
                        }
                    }
                    .safeAreaInset(edge: .bottom, content: {
                        Color.backgroundLightest.frame(height: 50)
                    })
                    .background(Color.backgroundLightest)
                }
            }
            .backgroundPreferenceValue(OffsetKey.self, { offset in
                VStack {
                    Color.backgroundLight.frame(height: max(offset, 0))
                    Color.backgroundLightest.frame(maxHeight: .infinity)
                }
            })
        }
    }
}

struct SearchResultsSection {
    let type: SearchResult.ContentType
    var expanded: Bool = false
    let results: [SearchResult]
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct CourseSmartSearchFilteredResultsView: View {

    @State private var resultSections: [SearchResultsSection]

    init(resultSections: [SearchResultsSection]) {
        self._resultSections = State(initialValue: resultSections)
    }

    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack(spacing: 0) {
                    SearchResultsHeaderView()
                        .anchorPreference(
                            key: OffsetKey.self,
                            value: .top,
                            transform: { anchor in
                                return g[anchor].y
                            })
                    LazyVStack(spacing: 0) {
                        ForEach($resultSections, id: \.type) { sec in
                            let section = sec.wrappedValue
                            let title = "\(section.type.title) (\(section.results.count))"

                            DisclosureGroup(title, isExpanded: sec.expanded) {
                                ForEach(section.results) { result in
                                    let last = section.results.last?.id == result.id
                                    SearchResultRow(result: result, showType: false, last: last)
                                }
                            }
                            .disclosureGroupStyle(.searchResultSection)
                        }
                    }
                    .safeAreaInset(edge: .bottom, content: {
                        Color.backgroundLightest.frame(height: 50)
                    })
                    .background(Color.backgroundLightest)
                }
            }
            .backgroundPreferenceValue(OffsetKey.self, { offset in
                VStack {
                    Color.backgroundLight.frame(height: max(offset, 0))
                    Color.backgroundLightest.frame(maxHeight: .infinity)
                }
            })
        }
    }
}

struct SearchResultsHeaderView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.searchContext) var searchContext

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Results in course")
                .lineLimit(1)
                .font(.regular16)
                .foregroundStyle(Color.textDark)
            Text(course()?.name ?? "")
                .font(.semibold16)
                .foregroundStyle(Color.textDarkest)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(Color.backgroundLightest)
        .cornerRadius(6)
        .shadow(color: Color(white: 0, opacity: 0.08), radius: 6, y: 2)
        .shadow(color: Color(white: 0, opacity: 0.16), radius: 2, y: 1)
        .padding(16)
        .background(Color.backgroundLight)
        .overlay(alignment: .bottom) {
            SearchDivider(inset: false)
        }
    }

    func course() -> Course? {
        if let course: Course = env
            .database
            .viewContext
            .fetch(scope: .where(#keyPath(Course.id), equals: searchContext.context.id)).first {
            return course
        }
        return nil
    }
}

struct SearchResultRow: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @Environment(\.searchContext) var searchContext

    var color: Color {
        Color(uiColor: searchContext.color ?? .gray)
    }

    let result: SearchResult
    var showType: Bool = true
    var last: Bool = false

    var body: some View {
        Button {
            let content = CoreHostingController(
                VStack(alignment: .leading) {
                    Text(result.title)
                    Text(result.content_type.rawValue)
                    Text(result.body)
                }
                    .padding()
            )
            env.router.show(content, from: controller, options: .detail)
        } label: {
            HStack(alignment: .top, spacing: 16) {
                result.content_type.icon.tint(color)
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.title).font(.semibold16).foregroundStyle(color)
                    if showType {
                        Text(result.content_type.rawValue).font(.regular14).foregroundStyle(color)
                    }
                    Text(result.body)
                        .font(.regular14)
                        .foregroundStyle(Color.textDark)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                Spacer()
                VStack {
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(1 ..< 5) { i in
                            Rectangle()
                                .fill(i <= result.distanceDots ? result.strengthColor : Color.borderMedium)
                                .frame(width: 4, height: 4)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 14)
            .overlay(alignment: .bottom) {
                SearchDivider(inset: last == false)
            }
        }
    }
}

struct SearchDivider: View {
    var inset: Bool = true
    var body: some View {
        Rectangle()
            .fill(Color.borderMedium)
            .frame(height: 0.5)
            .padding(.horizontal, inset ? 16 : 0)
    }
}

struct SearchResult: Codable, Identifiable {
    var id: ID { content_id }

    enum ContentType: String, Codable {
        case page = "Page"
        case assignment = "Assignment"
        case announcement = "Announcement"
        case discussion = "Discussion"
        case quiz = "Quiz"
        case file = "File"

        var title: String {
            switch self {
            case .file:
                return "File"
            case .page:
                return "Page"
            case .discussion:
                return "Discussion"
            case .assignment:
                return "Assignment"
            case .announcement:
                return "Announcement"
            case .quiz:
                return "Quiz"
            }
        }

        var icon: Image {
            switch self {
            case .file:
                Image.linkLine
            case .page:
                Image.documentLine
            case .discussion:
                Image.discussionLine
            case .assignment:
                Image.assignmentLine
            case .announcement:
                Image.announcementLine
            case .quiz:
                Image.quizLine
            }
        }

        var sortOrder: Int {
            switch self {
            case .page:
                return 1
            case .assignment:
                return 2
            case .announcement:
                return 3
            case .discussion:
                return 4
            case .quiz:
                return 5
            case .file:
                return 6
            }
        }
    }

    let content_id: ID
    let content_type: ContentType
    let title: String
    let body: String
    let html_url: URL?
    let distance: Double

    var distanceDots: Int {
        let strength = 1 - distance
        return Int(ceil(strength * 4))
    }

    var strengthColor: Color {
        return distanceDots >= 3 ? Color.borderSuccess : Color.borderWarning
    }
}

struct SearchResultSectionDisclosureStyle: DisclosureGroupStyle {

    @ScaledMetric private var uiScale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center) {
                    configuration
                        .label
                        .font(.semibold14)
                        .foregroundStyle(Color.textDark)
                    Spacer()
                    Image
                        .chevronDown
                        .size(uiScale.iconScale * 18)
                        .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .overlay(alignment: .bottom, content: { SearchDivider(inset: false) })
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

extension DisclosureGroupStyle where Self == SearchResultSectionDisclosureStyle {
    static var searchResultSection: Self { SearchResultSectionDisclosureStyle() }
}

extension SearchResult {

    static func make(_ type: ContentType, title: String, body: String) -> SearchResult {
        return SearchResult(
            content_id: ID(integerLiteral: Int.random(in: 1000 ... 9999)),
            content_type: type,
            title: title,
            body: body,
            html_url: URL(string: "https://www.instructure.com"),
            distance: Double.random(in: 0.1 ... 1.0)
        )
    }

    static var simpleExample: [SearchResult] {
        return [
            .make(
                .announcement,
                title: "Student Challenge",
                body: "We’re thrilled to announce the Swift Student Challenge 2025. The Challenge provides the next generation of student developers the opportunity to showcase their creativity and coding skills by building app playgrounds with Swift."
            ),
            .make(
                .assignment,
                title: "Entrepreneur Camp",
                body: "Apple Entrepreneur Camp supports underrepresented founders and developers, and encourages the pipeline and longevity of these entrepreneurs in technology. Attendees benefit from one-on-one code-level guidance, receive unprecedented access to Apple engineers and experts, and become part of the extended global network of Apple Entrepreneur Camp alumni."
            ),
            .make(
                .page,
                title: "Petra",
                body: "Petra is a famous archaeological site in Jordan's southwestern desert. Dating to around 300 B.C., it was the capital of the Nabatean Kingdom. Accessed via a narrow canyon called Al Siq, it contains tombs and temples carved into pink sandstone cliffs, earning its nickname, the \"Rose City.\" Perhaps its most famous structure is 45m-high Al Khazneh, a temple with an ornate, Greek-style facade, and known as The Treasury. "
            ),
            .make(
                .announcement,
                title: "Student Challenge",
                body: "We’re thrilled to announce the Swift Student Challenge 2025. The Challenge provides the next generation of student developers the opportunity to showcase their creativity and coding skills by building app playgrounds with Swift."
            ),
            .make(
                .quiz,
                title: "Capital of Hungary",
                body: "Budapest, Hungary’s capital, is bisected by the River Danube. Its 19th-century Chain Bridge connects the hilly Buda district with flat Pest. A funicular runs up Castle Hill to Buda’s Old Town, where the Budapest History Museum traces city life from Roman times onward. Trinity Square is home to 13th-century Matthias Church and the turrets of the Fishermen’s Bastion, which offer sweeping views."
            ),
            .make(
                .page,
                title: "Petra",
                body: "Petra is a famous archaeological site in Jordan's southwestern desert. Dating to around 300 B.C., it was the capital of the Nabatean Kingdom. Accessed via a narrow canyon called Al Siq, it contains tombs and temples carved into pink sandstone cliffs, earning its nickname, the \"Rose City.\" Perhaps its most famous structure is 45m-high Al Khazneh, a temple with an ornate, Greek-style facade, and known as The Treasury. "
            ),
            .make(
                .quiz,
                title: "Capital of Hungary",
                body: "Budapest, Hungary’s capital, is bisected by the River Danube. Its 19th-century Chain Bridge connects the hilly Buda district with flat Pest. A funicular runs up Castle Hill to Buda’s Old Town, where the Budapest History Museum traces city life from Roman times onward. Trinity Square is home to 13th-century Matthias Church and the turrets of the Fishermen’s Bastion, which offer sweeping views."
            ),
            .make(
                .announcement,
                title: "Student Challenge",
                body: "We’re thrilled to announce the Swift Student Challenge 2025. The Challenge provides the next generation of student developers the opportunity to showcase their creativity and coding skills by building app playgrounds with Swift."
            ),
            .make(
                .assignment,
                title: "Entrepreneur Camp",
                body: "Apple Entrepreneur Camp supports underrepresented founders and developers, and encourages the pipeline and longevity of these entrepreneurs in technology. Attendees benefit from one-on-one code-level guidance, receive unprecedented access to Apple engineers and experts, and become part of the extended global network of Apple Entrepreneur Camp alumni."
            )
        ]
    }
}
