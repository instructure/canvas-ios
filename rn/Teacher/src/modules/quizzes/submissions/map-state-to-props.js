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

// @flow

import { type SubmissionRowDataProps } from '../../submissions/list/SubmissionRow'
import { gradeProp, statusProp } from '../../submissions/list/get-submissions-props'
import { type QuizSubmissionListDataProps } from './QuizSubmissionList'
import shuffle from 'knuth-shuffle-seeded'

export function buildRows (enrollments: Enrollment[], quizSubmissions: { [string]: QuizSubmissionState }, submissions: { [string]: SubmissionState }): SubmissionRowDataProps[] {
  return enrollments.map((enrollment) => {
    const { user } = enrollment
    const quizSubmission = quizSubmissions[user.id]
    const submissionState = submissions[user.id]
    let grade = 'not_submitted'
    let status = 'none'
    let score
    let dueAt

    if (quizSubmission && quizSubmission.data) {
      score = quizSubmission.data.kept_score
      dueAt = quizSubmission.data.end_at
    }

    // If there is an actual submission object
    if (submissionState && submissionState.submission) {
      const submission = submissionState.submission
      grade = gradeProp(submission)
      status = statusProp(submission, dueAt)
    } else if (quizSubmission && quizSubmission.data) {
      status = 'submitted'
      const data = quizSubmission.data
      const keptScore = data.kept_score
      if (keptScore !== null && keptScore !== undefined) {
        grade = String(keptScore)
      }

      if (data.workflow_state === 'pending_review') {
        grade = 'ungraded'
      }

      if (Date.parse(data.end_at) < Date.now()) {
        status = 'late'
      }
    }

    return {
      userID: user.id,
      avatarURL: user.avatar_url,
      name: user.name,
      status,
      grade,
      score,
      anonymous: false, // this will be done in another commit
    }
  })
}

export default function mapStateToProps ({ entities }: AppState, { courseID, quizID }: any): QuizSubmissionListDataProps {
  let quiz = entities.quizzes[quizID]
  let quizSubmissions: { [string]: QuizSubmissionState } = {}
  let submissions: { [string]: SubmissionState } = {}
  let enrollments: Enrollment[] = []
  let pending = false
  let error = null
  let pointsPossible = 0
  let anonymous = false
  let muted = false
  let courseColor = '#FFFFFF'
  let courseName = ''

  if (quiz) {
    pending = Boolean(quiz.pending)
    pointsPossible = quiz.data.points_possible
    quiz.quizSubmissions.refs.map((r) => {
      return entities.quizSubmissions[r]
    })
    .filter((s) => s)
    .forEach((s) => { quizSubmissions[s.data.user_id] = s })

    quiz.submissions.refs.map((r) => {
      return entities.submissions[r]
    })
    .filter((s) => s)
    .forEach((s) => { submissions[s.submission.user_id] = s })

    if (quiz.data.assignment_id && entities.assignments && entities.assignments[quiz.data.assignment_id]) {
      anonymous = entities.assignments[quiz.data.assignment_id].anonymousGradingOn
      muted = entities.assignments[quiz.data.assignment_id].data.muted
    }
  }

  const course = entities.courses[courseID]
  if (course) {
    enrollments = course.enrollments.refs.map((r) => {
      return entities.enrollments[r]
    })
    .filter((r) => r)
    .filter((r) => r.type === 'StudentEnrollment')
    .reduce((accum, current) => {
      if (accum.findIndex(e => e.user_id === current.user_id) >= 0) {
        return accum
      }
      return [...accum, current]
    }, [])

    if (course.color) {
      courseColor = course.color
    }
    if (course.course) {
      courseName = course.course.name
    }
  }

  const rows = buildRows(enrollments, quizSubmissions, submissions)

  return {
    courseColor,
    courseName,
    rows: anonymous ? shuffle(rows, quiz.data.assignment_id) : rows,
    quiz,
    pending,
    pointsPossible,
    error,
    anonymous,
    muted,
  }
}
