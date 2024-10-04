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
import Translation

struct ContentDetailsView: View {
    // swiftlint:disable:next line_length
    @State private var text = """
    The content translation tool assists users in translating existing Wikipedia articles from one language to another. Users select an article in any language, then select another language, and the interface provides machine translation which the human user can then use as inspiration to make readable text in another language.

    Users should be familiar with the target language. Also, they should not publish the machine translation as is, but should proofread the translation, which usually contains strange wording and errors.
    """
    @State private var isTranslationAlertPresented = false
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        VStack {
            Text(text).textSelection(.enabled).padding()
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .navigationBarItems(trailing: translateButton)
        .navigationTitle("Content Details")
        .toolbarBackground(.visible, for: .navigationBar)
        .translationPresentation(
            isPresented: $isTranslationAlertPresented,
            text: text
        )
        .translationTask(configuration) { session in
            do {
               let translatedText =  try await session.translate(text)
                print(translatedText)
            } catch let error {
                print(error)
            }
        }
    }

    private var translateButton: some View {
        Button {
            if configuration == nil {
                self.configuration = TranslationSession.Configuration(source: nil, target: Locale.Language(identifier: "de-DE"))
            } else {
                self.configuration?.invalidate()
            }
        } label: {
            Image(systemName: "translate").foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
        }
    }

}

// v1
/*
 // swiftlint:disable:next line_length
 @State private var text = """
 The content translation tool assists users in translating existing Wikipedia articles from one language to another. Users select an article in any language, then select another language, and the interface provides machine translation which the human user can then use as inspiration to make readable text in another language.

 Users should be familiar with the target language. Also, they should not publish the machine translation as is, but should proofread the translation, which usually contains strange wording and errors.
 """
 @State private var isTranslationAlertPresented = false

 var body: some View {
     VStack {
         Text(text).padding()
         Spacer()
     }
     .frame(maxHeight: .infinity)
     .navigationBarItems(trailing: translateButton)
     .navigationTitle("Content Details")
     .toolbarBackground(.visible, for: .navigationBar)
     .translationPresentation(
         isPresented: $isTranslationAlertPresented,
         text: text
     )
 }

 private var translateButton: some View {
     Button {
         isTranslationAlertPresented = true
     } label: {
         Image(systemName: "translate").foregroundColor(.blue)
     }
 }
 */
