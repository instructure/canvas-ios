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

import mapStateToProps from '../map-state-to-props'
import shuffle from 'knuth-shuffle-seeded'

jest.mock('knuth-shuffle-seeded', () => jest.fn((input, seed) => input))

const template = {
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../__templates__/users'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/enrollments'),
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../__templates__/quizSubmission'),
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/section'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('QuizSubmissionList mapStateToProps', () => {
  it('works correctly with the best of the data', () => {
    const course = template.course()
    const quiz = template.quiz({
      assignment_id: '1',
    })

    const u1 = template.user({
      id: '1',
    })
    const e1 = template.enrollment({
      id: '1',
      user_id: u1.id,
      user: u1,
    })
    const qs1 = template.quizSubmission({
      id: '1',
      quiz_id: quiz.id,
      user_id: e1.user.id,
      workflow_state: 'pending_review',
    })

    const u2 = template.user({
      id: '2',
    })
    const e2 = template.enrollment({
      id: '2',
      user_id: u2.id,
      user: u2,
    })
    const s2 = template.submission({
      id: '2',
      user_id: e2.user.id,
      workflow_state: 'graded',
    })
    const qs2 = template.quizSubmission({
      id: '2',
      quiz_id: quiz.id,
      user_id: e2.user.id,
      submission_id: s2.id,
      kept_score: null,
    })

    const u3 = template.user({
      id: '3',
    })
    const e3 = template.enrollment({
      id: '3',
      user_id: u3.id,
      user: u3,
    })

    const u4 = template.user({
      id: '4',
    })
    const e4 = template.enrollment({
      id: '4',
      user_id: u4.id,
      user: u4,
    })
    const e4Dup = template.enrollment({
      id: '5',
      user_id: u4.id,
      user: u4,
    })

    const qs4 = template.quizSubmission({
      id: '4',
      quiz_id: quiz.id,
      user_id: u4.id,
      kept_score: null,
      end_at: (new Date(0)).toISOString(),
      overdue_and_needs_submission: true,
      workflow_state: 'untaken',
    })

    const appState = template.appState({
      entities: {
        courses: {
          [course.id]: { enrollments: { refs: [e1.id, e2.id, e3.id, e4.id, e4Dup.id] } },
        },
        assignments: {
          '1': {
            data: template.assignment({ anonymize_students: true }),
          },
        },
        enrollments: {
          [e1.id]: e1,
          [e2.id]: e2,
          [e3.id]: e3,
          [e4.id]: e4,
          [e4Dup.id]: e4Dup,
        },
        quizzes: {
          [quiz.id]: {
            data: quiz,
            quizSubmissions: { refs: [qs1.id, qs2.id, qs4.id] },
            submissions: { refs: [s2.id] },
          },
        },
        quizSubmissions: {
          [qs1.id]: { data: qs1 },
          [qs2.id]: { data: qs2 },
          [qs4.id]: { data: qs4 },
        },
        submissions: {
          [s2.id]: { submission: s2 },
        },
        sections: [template.section({ course_id: course.id })],
      },
    })

    const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
    expect(result).toMatchObject({
      quiz: { data: quiz },
      rows: [
        {
          userID: '1',
          grade: 'ungraded',
          status: 'submitted',
          sectionID: '1',
        },
        {
          userID: '2',
          grade: 'B-',
          status: 'submitted',
          sectionID: '1',
        },
        {
          userID: '3',
          grade: 'not_submitted',
          status: 'none',
          sectionID: '1',
        },
        {
          userID: '4',
          grade: 'not_submitted',
          status: 'late',
          sectionID: '1',
        },
      ],
      anonymous: true,
    })
    expect(shuffle).toHaveBeenCalled()
  })

  it('ignores grade data if pending review', () => {
    const course = template.course()
    const quiz = template.quiz({
      assignment_id: '1',
    })

    const u1 = template.user({
      id: '1',
    })
    const e1 = template.enrollment({
      id: '1',
      user_id: u1.id,
      user: u1,
    })
    const qs1 = template.quizSubmission({
      id: '1',
      quiz_id: quiz.id,
      user_id: e1.user.id,
      workflow_state: 'pending_review',
    })

    const u2 = template.user({
      id: '2',
    })
    const e2 = template.enrollment({
      id: '2',
      user_id: u2.id,
      user: u2,
    })
    const s2 = template.submission({
      id: '2',
      user_id: e2.user.id,
      workflow_state: 'pending_review',
    })
    const qs2 = template.quizSubmission({
      id: '2',
      quiz_id: quiz.id,
      user_id: e2.user.id,
      submission_id: s2.id,
      kept_score: null,
    })

    const appState = template.appState({
      entities: {
        courses: {
          [course.id]: { enrollments: { refs: [e1.id, e2.id] } },
        },
        assignments: {
          '1': {
            data: template.assignment({ anonymize_students: true }),
          },
        },
        enrollments: {
          [e1.id]: e1,
          [e2.id]: e2,
        },
        quizzes: {
          [quiz.id]: {
            data: quiz,
            quizSubmissions: { refs: [qs1.id, qs2.id] },
            submissions: { refs: [s2.id] },
          },
        },
        quizSubmissions: {
          [qs1.id]: { data: qs1 },
          [qs2.id]: { data: qs2 },
        },
        submissions: {
          [s2.id]: { submission: s2 },
        },
        sections: [template.section({ course_id: course.id })],
      },
    })

    const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
    expect(result).toMatchObject({
      quiz: { data: quiz },
      rows: [
        {
          userID: '1',
          grade: 'ungraded',
          status: 'submitted',
          sectionID: '1',
        },
        {
          userID: '2',
          grade: 'ungraded',
          status: 'submitted',
          sectionID: '1',
        },
      ],
      anonymous: true,
    })
  })

  it('should still work and not explode with missing data', () => {
    const course = template.course()
    const quiz = template.quiz()
    const appState = template.appState()
    const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
    expect(result).toMatchObject({
      rows: [],
      quiz: undefined,
      anonymous: false,
    })
  })

  it('will set anonymous to true if the quiz has anonymous submissions turned on', () => {
    const course = template.course()
    const quiz = template.quiz({
      anonymous_submissions: true,
    })
    const appState = template.appState({
      entities: {
        courses: {
          [course.id]: { enrollments: { refs: [] } },
        },
        enrollments: {},
        quizzes: {
          [quiz.id]: {
            data: quiz,
            quizSubmissions: { refs: [] },
            submissions: { refs: [] },
          },
        },
        quizSubmissions: {},
        submissions: {},
        sections: [template.section({ course_id: course.id })],
      },
    })
    const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
    expect(result).toMatchObject({
      anonymous: true,
    })
    expect(shuffle).toHaveBeenCalled()
  })
})
