// @flow

import mapStateToProps from '../map-state-to-props'
import moment from 'moment'

const template = {
  ...require('../../../../api/canvas-api/__templates__/quiz'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../../api/canvas-api/__templates__/quizSubmission'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('QuizSubmissionList mapStateToProps', () => {
  test('works correctly with the best of the data', () => {
    const course = template.course()
    const quiz = template.quiz()

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

    const qs4 = template.quizSubmission({
      id: '4',
      quiz_id: quiz.id,
      user_id: u4.id,
      kept_score: null,
      end_at: moment().subtract(1, 'days').format(),
    })

    const appState = template.appState({
      entities: {
        courses: {
          [course.id]: { enrollments: { refs: [e1.id, e2.id, e3.id, e4.id] } },
        },
        enrollments: {
          [e1.id]: e1,
          [e2.id]: e2,
          [e3.id]: e3,
          [e4.id]: e4,
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
        },
        {
          userID: '2',
          grade: 'B-',
          status: 'submitted',
        },
        {
          userID: '3',
          grade: 'not_submitted',
          status: 'none',
        },
        {
          userID: '4',
          grade: 'not_submitted',
          status: 'late',
        },
      ],
    })
  })

  test('missing data and it should still work and not explode', () => {
    const course = template.course()
    const quiz = template.quiz()
    const appState = template.appState()
    const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
    expect(result).toMatchObject({
      rows: [],
      quiz: undefined,
    })
  })
})
