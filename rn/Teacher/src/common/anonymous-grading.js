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

// @flow

// Checks if quiz is anonymous according to the api
export function isQuizAnonymous (appState: AppState, quizID: string) {
  const quiz = appState.entities.quizzes[quizID]
  return Boolean(quiz && quiz.data && quiz.data.anonymous_submissions)
}

// Checks if assignment is anonymous according to the api
export function isAssignmentAnonymous (appState: AppState, courseID: string, assignmentID: string) {
  const { entities } = appState
  const { assignments } = entities
  const assignment = assignments[assignmentID]
  if (assignment && assignment.data) {
    // Quizzes have their own flag
    if (assignment.data.quiz_id) {
      return isQuizAnonymous(appState, assignment.data.quiz_id)
    }

    return Boolean(assignment.data.anonymize_students)
  }

  return false
}
