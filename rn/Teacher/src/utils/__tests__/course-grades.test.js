//
// Copyright (C) 2016-present Instructure, Inc.
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
