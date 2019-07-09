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

// @flow

import { submissions } from '../submission-refs-reducer'
import Actions from '../actions'
import QuizSubmissionActions from '../../../quizzes/submissions/actions'
import SpeedGraderActions from '../../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { refreshQuizSubmissions } = QuizSubmissionActions
const { excuseAssignment, gradeSubmission } = SpeedGraderActions

const templates = {
  ...require('../../../../__templates__/submissions'),
}

test('it captures submission ids', () => {
  let data = [
    { id: '1' },
    { id: '2' },
  ].map(override => templates.submissionHistory([override]))

  const pending = {
    type: refreshSubmissions.toString(),
    pending: true,
  }
  const resolved = {
    type: refreshSubmissions.toString(),
    payload: { result: { data } },
  }

  const pendingState = submissions(undefined, pending)
  expect(pendingState).toEqual({ refs: [], pending: 1 })
  expect(submissions(pendingState, resolved)).toEqual({
    pending: 0,
    refs: ['1', '2'],
  })
})

test('it captures quiz submission ids', () => {
  let data = [
    templates.submission({ id: '1' }),
    templates.submission({ id: '2' }),
  ]

  const pending = {
    type: refreshQuizSubmissions.toString(),
    pending: true,
  }
  const resolved = {
    type: refreshQuizSubmissions.toString(),
    payload: {
      result: {
        data: {
          submissions: data,
        },
      },
    },
  }

  const pendingState = submissions(undefined, pending)
  expect(pendingState).toEqual({ refs: [], pending: 1 })
  expect(submissions(pendingState, resolved)).toEqual({
    pending: 0,
    refs: ['1', '2'],
  })
})

test('on excuseAssignment it returns the current state when there is a submissionID', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: excuseAssignment.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('excuseAssignment adds the new submission id to the refs', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: excuseAssignment.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
    },
  }

  let newState = submissions(state, action)
  expect(newState.refs.length).toEqual(1)
  expect(newState.refs[0]).toEqual('1')
})

test('on gradeSubmission it returns the current state when there is a submissionID', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: gradeSubmission.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('on gradeSubmission it adds the new submission id to the refs', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: gradeSubmission.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
    },
  }

  let newState = submissions(state, action)
  expect(newState.refs.length).toEqual(1)
  expect(newState.refs[0]).toEqual('1')
})
