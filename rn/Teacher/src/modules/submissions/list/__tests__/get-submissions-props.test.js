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

// @flow

import { gradeProp, statusProp } from '../get-submissions-props'
import app from '../../../app'
import * as template from '../../../../__templates__'

describe('GetSubmissionsProps gradeProp', () => {
  beforeEach(() => {
    app.setCurrentApp('teacher')
  })

  test('null submission', () => {
    const result = gradeProp(null)
    expect(result).toEqual('not_submitted')
  })

  test('unsubmitted submission', () => {
    const submission = template.submission({
      grade: null,
      submitted_at: null,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('not_submitted')
  })

  test('excused submission', () => {
    const submission = template.submission({
      excused: true,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('excused')
  })

  test('graded submission', () => {
    const grade = '33'
    const submission = template.submission({
      grade: grade,
      workflow_state: 'graded',
    })

    const result = gradeProp(submission)
    expect(result).toEqual(grade)
  })

  test('ungraded submission', () => {
    const submission = template.submission({
      grade_matches_current_submission: false,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('ungraded')
  })

  test('pending review', () => {
    const submission = template.submission({
      grade: 12,
      workflow_state: 'pending_review',
    })
    expect(gradeProp(submission)).toEqual('ungraded')
  })

  describe('statusProp', () => {
    it('considers the submission missing if the flag is true', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'pending_review',
        missing: true,
      })
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(submission, dueDate)).toEqual('missing')
    })

    it('considers null submission missing', () => {
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(null, dueDate)).toEqual('missing')
    })

    it('considers worflow unsubmitted missing', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'unsubmitted',
      })

      const dueDate = new Date().toUTCString()
      expect(statusProp(submission, dueDate)).toEqual('missing')
    })

    it('considers pending_review submitted', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'pending_review',
      })
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(submission, dueDate)).toEqual('submitted')
    })

    it('considers pending_review late is passed due date', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'pending_review',
        late: true,
      })
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(submission, dueDate)).toEqual('late')
    })
  })

  it('returns grade for students', () => {
    app.setCurrentApp('student')
    const submission = template.submission({
      excused: false,
      grade: 'A-',
      submitted_at: '2018-04-11T05:59:00Z',
    })
    expect(gradeProp(submission)).toEqual('A-')
  })
})
