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
    
    

import Foundation



extension QuizIntroViewController {
    public convenience init(session: Session, quizURL: URL, quizID: String) {
        let components = NSURLComponents(url:quizURL, resolvingAgainstBaseURL: false)
        components?.path = nil
        components?.query = nil
        components?.fragment = nil

        let context = ContextID(url: quizURL)!
        let service = CanvasQuizService(session: session, context: context, quizID: quizID)
        let controller = QuizController(service: service, quiz: nil)

        self.init(quizController: controller)
    }
}
