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

import {
  isQuizAnonymous,
  isAssignmentAnonymous,
} from '../anonymous-grading'
import * as template from '../../__templates__'

describe('isQuizAnonymous', () => {
  it('is true if anonymous_submissions is true', () => {
    const quiz = template.quiz({ anonymous_submissions: true })
    const state = template.appState({
      entities: {
        quizzes: {
          [quiz.id]: {
            data: quiz,
          },
        },
      },
    })
    const result = isQuizAnonymous(state, quiz.id)
    expect(result).toEqual(true)
  })

  it('is false if the quiz does not exist', () => {
    const state = template.appState({
      entities: {
        quizzes: {},
      },
    })
    const result = isQuizAnonymous(state, '1')
    expect(result).toEqual(false)
  })

  it('is false if anonymous_submissions is false', () => {
    const quiz = template.quiz({ anonymous_submissions: false })
    const state = template.appState({
      entities: {
        quizzes: {
          [quiz.id]: {
            data: quiz,
          },
        },
      },
    })
    const result = isQuizAnonymous(state, quiz.id)
    expect(result).toEqual(false)
  })
})

describe('isAssignmentAnonymous', () => {
  it('is true if the assignment has anonymize_students set to true', () => {
    const assignment = template.assignment({ anonymize_students: true })
    const state = template.appState({
      entities: {
        assignments: {
          [assignment.id]: {
            data: assignment,
          },
        },
      },
    })
    const result = isAssignmentAnonymous(state, '', assignment.id)
    expect(result).toEqual(true)
  })

  it('is true if the assignment is an anonymous quiz', () => {
    const quiz = template.quiz({ anonymous_submissions: true })
    const assignment = template.assignment({ quiz_id: quiz.id })
    const state = template.appState({
      entities: {
        assignments: {
          [assignment.id]: {
            data: assignment,
          },
        },
        quizzes: {
          [quiz.id]: {
            data: quiz,
          },
        },
      },
    })
    const result = isAssignmentAnonymous(state, '', assignment.id)
    expect(result).toEqual(true)
  })

  it('is false if the assignment does not exist', () => {
    const state = template.appState({
      entities: {
        courses: {
          '1': {},
        },
        assignments: {},
      },
    })
    const result = isAssignmentAnonymous(state, '1', '2')
    expect(result).toEqual(false)
  })
})
