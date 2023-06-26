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

struct DashboardCourseCardView: View {
    @ObservedObject var courseCard: DashboardCard
    let hideColorOverlay: Bool
    let showGrade: Bool
    let width: CGFloat
    let contextColor: UIColor
    /** Wide layout puts the course image to the left of the cell while the course name and code will be next to it on the right. */
    let isWideLayout: Bool
    @Binding var isAvailable: Bool
    @State private var isShowingKebabDialog = false

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var a11yGrade: String {
        guard let course = courseCard.course, showGrade else { return "" }
        return course.displayGrade
    }

    var body: some View {
        PrimaryButton(isAvailable: $isAvailable) {
            env.router.route(to: "/courses/\(courseCard.id)?contextColor=\(contextColor.hexString.dropFirst())", from: controller)
        } label: {
            ZStack(alignment: .topLeading) {
                if isWideLayout {
                    regularHorizontalLayout
                } else {
                    compactHorizontalLayout
                }
                gradePill
                    .accessibility(hidden: true) // handled in the button label
                    .offset(x: 8, y: 8)
                    .zIndex(1)
            }
        }
        .buttonStyle(ScaleButtonStyle(scale: 1))
        .accessibility(label: Text(verbatim: "\(courseCard.shortName) \(courseCard.courseCode) \(a11yGrade)".trimmingCharacters(in: .whitespacesAndNewlines)))
        .identifier("DashboardCourseCell.\(courseCard.id)")
    }

    private var regularHorizontalLayout: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 1.77 to have 16:9 ratio
                courseImage(width: 1.77 * geometry.size.height, height: geometry.size.height)
                textArea
            }
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1 / UIScreen.main.scale))
            .background(Color.backgroundLightest)
            .cornerRadius(4)
        }
    }

    private var compactHorizontalLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            courseImage(width: width)
            textArea
        }
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1 / UIScreen.main.scale))
        .background(Color.backgroundLightest)
        .cornerRadius(4)
    }

    private func courseImage(width: CGFloat, height: CGFloat = 80) -> some View {
        ZStack(alignment: .topLeading) {
            Color(courseCard.color).frame(width: width, height: height)
            courseCard.imageURL.map { RemoteImage($0, width: width, height: height) }?
                .opacity(hideColorOverlay ? 1 : 0.4)
                .clipped()
                // Fix big course image consuming tap events.
                .contentShape(Path(CGRect(x: 0, y: 0, width: width, height: height)))
            optionsKebabButton
                .offset(x: width - 44, y: 0)
        }
    }

    private var textArea: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack { Spacer() }
            Text(courseCard.shortName)
                .font(.semibold18).foregroundColor(Color(courseCard.color))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            Text(courseCard.courseCode)
                .font(.semibold12).foregroundColor(.textDark)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 10).padding(.top, 8)
    }

    @ViewBuilder
    private var optionsKebabButton: some View {
        PrimaryButton(isAvailable: $isAvailable) {
            if ExperimentalFeature.offlineMode.isEnabled, env.app == .student {
                isShowingKebabDialog.toggle()
            } else {
                openDashboardCardCustomizeSheet()
            }
        } label: {
            kebabIcon
        }
        .frame(width: 44, height: 44).padding(.trailing, -6)
        .accessibilityLabel(Text("Course Card Options", bundle: .core))
        .identifier("DashboardCourseCell.\(courseCard.id).optionsButton")
        .confirmationDialog("", isPresented: $isShowingKebabDialog) {
            Button {
                var route = "/offline/sync_picker"

                if let courseID = courseCard.course?.id {
                    route.append("/\(courseID)")
                }

                env.router.route(to: route,
                                 from: controller,
                                 options: .modal(isDismissable: false, embedInNav: true))
            } label: {
                Text("Manage Offline Content", bundle: .core)
            }
            PrimaryButton {
                openDashboardCardCustomizeSheet()
            } label: {
                Text("Customize Course", bundle: .core)
            }
        }
    }

    private var kebabIcon: some View {
        Image.moreSolid
            .foregroundColor(Color(contextColor))
            .background(
                Circle()
                    .fill(Color.backgroundLightest)
                    .frame(width: 28, height: 28)
            )
            .frame(width: 44, height: 44)
    }

    @ViewBuilder
    private var gradePill: some View {
        if showGrade, let course = courseCard.course {
            HStack {
                if course.hideTotalGrade {
                    Image.lockSolid.size(14)
                } else {
                    Text(course.displayGrade).font(.semibold14)
                }
            }
            .foregroundColor(Color(contextColor))
            .padding(.horizontal, 6).frame(height: 20)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundLightest))
            .frame(maxWidth: 120, alignment: .leading)
        }
    }

    private func openDashboardCardCustomizeSheet() {
        guard let course = courseCard.course else { return }
        env.router.show(
            CoreHostingController(CustomizeCourseView(course: course, hideColorOverlay: hideColorOverlay)),
            from: controller,
            options: .modal(.formSheet, isDismissable: false, embedInNav: true),
            analyticsRoute: "/dashboard/customize_course"
        )
    }
}

#if DEBUG

struct CourseCard_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext
    private static var courseCard: DashboardCard {
        let apiEnrollment = APIEnrollment.make(computed_current_score: 105, computed_current_grade: "A+")
        let apiCourse = APICourse.make(enrollments: [apiEnrollment])
        Course.save(apiCourse, in: context)

        let apiContextColor = APICustomColors(custom_colors: ["course_1": "#008EE2"])
        ContextColor.save(apiContextColor, in: context)

        let apiEntity = APIDashboardCard.make(courseCode: "Course_PRV_001_2023/03/03-Term1-Section3",
                                              shortName: "Mrs. Robinson's Reading Lectures For Elementary Class")
        return DashboardCard.save(apiEntity, position: 0, in: context)
    }

    static var previews: some View {
        VStack(alignment: .leading) {
            Text(verbatim: "Grid Layout")
            DashboardCourseCardView(courseCard: courseCard,
                       hideColorOverlay: false,
                       showGrade: true,
                       width: 200,
                       contextColor: .electric,
                       isWideLayout: false,
                                    isAvailable: .constant(true))
            .frame(width: 200, height: 160)
            .environment(\.horizontalSizeClass, .compact)

            Text(verbatim: "List Layout - Compact Horizontal Size Class").padding(.top)
            DashboardCourseCardView(courseCard: courseCard,
                       hideColorOverlay: false,
                       showGrade: true,
                       width: 400,
                       contextColor: .electric,
                       isWideLayout: false,
                       isAvailable: .constant(true))
            .frame(width: 400, height: 160)
            .environment(\.horizontalSizeClass, .compact)

            Text(verbatim: "List Layout - Regular Horizontal Size Class").padding(.top)
            DashboardCourseCardView(courseCard: courseCard,
                       hideColorOverlay: false,
                       showGrade: true,
                       width: 900,
                       contextColor: .electric,
                       isWideLayout: true,
                       isAvailable: .constant(true))
            .frame(width: 900, height: 100)
            .environment(\.horizontalSizeClass, .regular)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

#endif
