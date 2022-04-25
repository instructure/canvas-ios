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

import SwiftUI

struct K5GradesView: View {

    @ObservedObject private var viewModel: K5GradesViewModel
    @State var gradeSelectorOpen = false

    init(viewModel: K5GradesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            gradingPeriodSelector
            Spacer()
            ScrollView(showsIndicators: false) {
                CircleRefresh { endRefreshing in
                    viewModel.refresh(completion: endRefreshing)
                }
                ForEach(viewModel.grades) {
                    K5GradeCell(with: $0)
                    Divider()
                }
            }
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                gradeSelectorOpen = false
            }
        }
    }

    private var gradingPeriodSelector: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Select", bundle: .core)
                    .font(.regular13)
                    .background(Color.white)
                    .foregroundColor(.ash)
                    .padding(.top, 15)
                    .accessibility(hidden: true)
                HStack(spacing: 7) {
                    let selectorStateText = gradeSelectorOpen ? Text("Open", bundle: .core) : Text("Closed", bundle: .core)
                    Button(action: {
                        withAnimation {
                            gradeSelectorOpen.toggle()
                        }
                    }, label: {
                        Text(viewModel.currentGradingPeriod.title ?? "")
                            .font(.bold24)
                            .foregroundColor(.licorice)
                    })
                    .accessibility(label: Text("Select grading period", bundle: .core) + Text(verbatim: ", ") + selectorStateText)
                    .accessibility(hint: Text(verbatim: ", \(viewModel.currentGradingPeriod.title ?? "") ,") + Text("Selected", bundle: .core))

                    Image.arrowOpenDownLine
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.licorice)
                        .rotationEffect(.degrees(gradeSelectorOpen ? -180 : 0))
                        .animation(.easeOut)
                        .accessibility(hidden: true)
                    Spacer()
                }
                .padding(.bottom, 13)
                Divider()
            }
            .zIndex(1)
            .background(Color.white)
            .padding(.top, 0)

            if gradeSelectorOpen {
                VStack(alignment: .leading) {
                    ForEach(viewModel.gradingPeriods, id: \.self) { gradingPeriod in
                        Button {
                            viewModel.didSelect(gradingPeriod: gradingPeriod)
                            withAnimation {
                                gradeSelectorOpen = false
                            }
                        } label: {
                            Text(gradingPeriod.title ?? "").font(.bold20).background(Color.white).foregroundColor(.licorice)
                        }.padding(.bottom, 1)
                        Divider()
                    }
                }.transition(.move(edge: .top))
            }
        }
        .clipped()
    }
}

#if DEBUG

struct K5GradesView_Previews: PreviewProvider {
    static var previews: some View {
        K5GradesView(viewModel: K5GradesViewModel() )
    }
}

#endif
