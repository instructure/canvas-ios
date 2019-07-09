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

import i18n from 'format-message'

export type CourseGradeInfo = {
  currentGrade: string,
  currentScore: number,
  currentDisplay: ?string,
  finalGrade: string,
  finalScore: number,
  finalDisplay: ?string,
}

export function extractGradeInfo (course: Course): ?CourseGradeInfo {
  const enrollments = course.enrollments
  if (!enrollments) return null
  const enrollment = enrollments.find(({ type }) => type === 'student')
  if (!enrollment) return null

  const createDisplay = (score: ?number, grade: ?string): ?string => {
    if (!score && !grade) return ''
    if (!score) return grade
    return [i18n.number(score / 100, 'percent'), grade].filter(a => a).join(' - ')
  }

  if (enrollment.multiple_grading_periods_enabled && enrollment.current_grading_period_id) {
    return {
      currentGrade: enrollment.current_period_computed_current_grade,
      currentScore: enrollment.current_period_computed_current_score,
      currentDisplay: createDisplay(enrollment.current_period_computed_current_score, enrollment.current_period_computed_current_grade),
      finalGrade: enrollment.current_period_computed_final_grade,
      finalScore: enrollment.current_period_computed_final_score,
      finalDisplay: createDisplay(enrollment.current_period_computed_final_score, enrollment.current_period_computed_final_grade),
    }
  } else {
    return {
      currentGrade: enrollment.computed_current_grade,
      currentScore: enrollment.computed_current_score,
      currentDisplay: createDisplay(enrollment.computed_current_score, enrollment.computed_current_grade),
      finalGrade: enrollment.computed_final_grade,
      finalScore: enrollment.computed_final_score,
      finalDisplay: createDisplay(enrollment.computed_final_score, enrollment.computed_final_grade),
    }
  }
}
