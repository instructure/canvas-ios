//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import {
  isQuizAnonymous,
  isAssignmentAnonymous,
} from '../anonymous-grading'
import * as template from '../../__templates__'
import {
  enableAllFeaturesFlagsForTesting,
  disableAllFeatureFlagsForTesting,
} from '../feature-flags'

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

  // TODO: Remove this with assignmentLevelAnonymousGrading feature flag
  describe('using deprecated course setting', () => {
    beforeEach(() => {
      disableAllFeatureFlagsForTesting()
    })

    afterEach(() => {
      enableAllFeaturesFlagsForTesting()
    })

    it('is true if feature enabled', () => {
      const assignment = template.assignment()
      const state = template.appState({
        entities: {
          courses: {
            '1': {
              enabledFeatures: ['anonymous_marking'],
            },
          },
          assignments: {
            [assignment.id]: {
              data: assignment,
            },
          },
        },
      })
      const result = isAssignmentAnonymous(state, '1', assignment.id)
      expect(result).toEqual(true)
    })

    it('is false if feature is not enabled', () => {
      const assignment = template.assignment()
      const state = template.appState({
        entities: {
          courses: {
            '1': {
              enabledFeatures: [],
            },
          },
          assignments: {
            [assignment.id]: {
              data: assignment,
            },
          },
        },
      })
      const result = isAssignmentAnonymous(state, '1', assignment.id)
      expect(result).toEqual(false)
    })
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
