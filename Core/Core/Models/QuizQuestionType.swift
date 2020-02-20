//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation

public enum QuizQuestionType: String, Codable, CaseIterable {
    case calculated_question, essay_question, file_upload_question, fill_in_multiple_blanks_question,
        matching_question, multiple_answers_question, multiple_choice_question, multiple_dropdowns_question,
        numerical_question, short_answer_question, text_only_question, true_false_question
}
