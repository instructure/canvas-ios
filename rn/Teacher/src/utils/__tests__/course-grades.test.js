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

/* @flow */

import { extractGradeInfo } from '../course-grades'

const template = {
  ...require('../../__templates__/course'),
}

describe('course grade utils', () => {
  describe('extractGradeInfo', () => {
    it('extracts when multiple_grading_periods_enabled is enabled', () => {
      const course = template.course({
        enrollments: [{
          type: 'student',
          current_grading_period_id: '1',
          multiple_grading_periods_enabled: true,
          current_period_computed_current_grade: 'A-',
          current_period_computed_current_score: '92.3',
        }],
      })

      const result = extractGradeInfo(course)
      expect(result).toMatchObject({
        currentGrade: 'A-',
        currentDisplay: '92.3% - A-',
      })
    })

    it('does not use period grades when no current period', () => {
      const course = template.course({
        enrollments: [{
          type: 'student',
          current_grading_period_id: null,
          multiple_grading_periods_enabled: true,
          computed_current_grade: 'A-',
          computed_current_score: '92.3',
        }],
      })

      const result = extractGradeInfo(course)
      expect(result).toMatchObject({
        currentGrade: 'A-',
        currentDisplay: '92.3% - A-',
      })
    })

    it('extracts when multiple_grading_periods_enabled is not enabled', () => {
      const course = template.course({
        enrollments: [{
          type: 'student',
          multiple_grading_periods_enabled: false,
          computed_current_grade: 'A-',
          computed_current_score: '92.3',
        }],
      })

      const result = extractGradeInfo(course)
      expect(result).toMatchObject({
        currentGrade: 'A-',
        currentDisplay: '92.3% - A-',
      })
    })

    it('handles edge case when there is a grade but not a score (which should not actually be possible)', () => {
      const course = template.course({
        enrollments: [{
          type: 'student',
          multiple_grading_periods_enabled: false,
          computed_current_grade: 'A-',
        }],
      })

      const result = extractGradeInfo(course)
      expect(result).toMatchObject({
        currentGrade: 'A-',
        currentDisplay: 'A-',
      })
    })

    it('handles no enrollments', () => {
      let result = extractGradeInfo(template.course({}))
      expect(result).toBeNull()

      result = extractGradeInfo(template.course({ enrollments: [] }))
      expect(result).toBeNull()
    })
  })
})
