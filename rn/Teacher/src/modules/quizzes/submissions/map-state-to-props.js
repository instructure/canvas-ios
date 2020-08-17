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

/* eslint-disable flowtype/require-valid-file-annotation */

import { type SubmissionRowDataProps } from '../../submissions/list/SubmissionRow'
import { gradeProp, statusProp } from '../../submissions/list/get-submissions-props'
import { type QuizSubmissionListDataProps } from './QuizSubmissionList'
import shuffle from 'knuth-shuffle-seeded'
import {
  isQuizAnonymous,
  isAssignmentAnonymous,
} from '../../../common/anonymous-grading'

export function buildRows (enrollments: Enrollment[],
  quizSubmissions: { [string]: QuizSubmissionState },
  submissions: { [string]: SubmissionState },
  sectionIDs: [string]): SubmissionRowDataProps[] {
  return enrollments.map((enrollment) => {
    const { user } = enrollment
    const quizSubmission = quizSubmissions[user.id]
    const submissionState = submissions[user.id]
    let grade = 'not_submitted'
    let status = 'none'
    let score
    let dueAt

    if (submissionState && submissionState.submission) {
      // use assignment submission data for graded quiz submissions
      const submission = submissionState.submission
      grade = gradeProp(submission)
      status = statusProp(submission, dueAt)
      score = submission.score // same as quiz submission keptScore
    } else if (quizSubmission && quizSubmission.data) {
      // only use quiz submission data for ungraded quizzes
      // note: ungraded quiz submissions always have a null data.end_at
      const data = quizSubmission.data
      const keptScore = data.kept_score
      if (keptScore !== null && keptScore !== undefined) {
        score = keptScore
        grade = String(keptScore)
      }

      if (data.workflow_state === 'complete') {
        status = 'submitted'
      }

      if (data.workflow_state === 'untaken') {
        grade = 'not_submitted'
        if (data.overdue_and_needs_submission) {
          status = 'late'
        }
      }

      if (data.workflow_state === 'pending_review') {
        status = 'submitted'
        grade = 'ungraded'
      }
    }

    return {
      userID: user.id,
      avatarURL: user.avatar_url,
      name: user.name,
      status,
      grade,
      score,
      sectionID: enrollment.course_section_id,
      allSectionIDs: sectionIDs[user.id],
      gradingType: 'points',
    }
  })
}

export default function mapStateToProps (state: AppState, { courseID, quizID }: any): QuizSubmissionListDataProps {
  const { entities } = state
  let quiz = entities.quizzes[quizID]
  let quizSubmissions: { [string]: QuizSubmissionState } = {}
  let submissions: { [string]: SubmissionState } = {}
  let enrollments: Enrollment[] = []
  let sectionIDs: [string] = []
  let pending = false
  let error = null
  let pointsPossible = 0
  let anonymous = false
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

    anonymous = isQuizAnonymous(state, quizID)
    if (quiz.data.assignment_id) {
      anonymous = anonymous || isAssignmentAnonymous(state, courseID, quiz.data.assignment_id)
    }
  }

  const course = entities.courses[courseID]
  if (course) {
    const allEnrollments = course.enrollments.refs.map((r) => {
      return entities.enrollments[r]
    })

    sectionIDs = allEnrollments.reduce((memo, enrollment) => {
      const userID = enrollment.user_id
      const existing = memo[userID] || []
      return { ...memo, [userID]: [...existing, enrollment.course_section_id] }
    }, {})

    enrollments = allEnrollments.filter((e) => {
      if (!e) return false
      return (e.type === 'StudentEnrollment' ||
              e.type === 'StudentViewEnrollment') &&
              (e.enrollment_state === 'active' ||
              e.enrollment_state === 'invited')
    })
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

  const sections = Object.values(entities.sections).filter((s) => {
    return s.course_id === courseID
  })

  const rows = buildRows(enrollments, quizSubmissions, submissions, sectionIDs)

  return {
    courseColor,
    courseName,
    rows: anonymous ? shuffle(rows, quiz.data.id) : rows,
    quiz,
    pending,
    pointsPossible,
    error,
    anonymous,
    sections,
  }
}
