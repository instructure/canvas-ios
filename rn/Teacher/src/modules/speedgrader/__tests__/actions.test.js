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

import { SpeedGraderActions } from '../actions'

let api = {
  gradeSubmission: jest.fn(),
  gradeSubmissionWithRubric: jest.fn(),
}

let actions = SpeedGraderActions(api)

describe('SpeedGraderActions', () => {
  beforeEach(() => jest.resetAllMocks())

  describe('excuseAssignment', () => {
    it('calls gradeSubmission with the correct arguments', () => {
      actions.excuseAssignment('1', '2', '3', '4')
      expect(api.gradeSubmission).toHaveBeenCalledWith('1', '2', '3', { excuse: true })
    })

    it('passes the submissionID and assignmentID in the action payload', () => {
      let { payload } = actions.excuseAssignment('1', '2', '3', '4')
      expect(payload).toHaveProperty('submissionID', '4')
      expect(payload).toHaveProperty('assignmentID', '2')
    })
  })

  describe('gradeSubmission', () => {
    it('calls gradeSubmission with the correct arguments', () => {
      actions.gradeSubmission('1', '2', '3', '4', '1234')
      expect(api.gradeSubmission).toHaveBeenCalledWith('1', '2', '3', { posted_grade: '1234' })
    })

    it('passes the submissionID and assignmentID in the action payload', () => {
      let { payload } = actions.gradeSubmission('1', '2', '3', '4', '1234')
      expect(payload).toHaveProperty('submissionID', '4')
      expect(payload).toHaveProperty('assignmentID', '2')
      expect(payload).toHaveProperty('handlesError', true)
    })
  })

  describe('selectSubmissionFromHistory', () => {
    it('passes the submissionID and index in the action payload', () => {
      let { payload } = actions.selectSubmissionFromHistory('1', 2)
      expect(payload).toHaveProperty('submissionID', '1')
      expect(payload).toHaveProperty('index', 2)
    })
  })

  describe('selectFile', () => {
    it('passes the submissionID and index in the action payload', () => {
      let { payload } = actions.selectFile('1', 2)
      expect(payload).toHaveProperty('submissionID', '1')
      expect(payload).toHaveProperty('index', 2)
    })
  })

  describe('gradeSubmissionWithRubric', () => {
    it('calls gradeSubmissionWithRubric with the correct arguments', () => {
      let params = {
        '1': { comments: '', points: 10 },
      }
      actions.gradeSubmissionWithRubric('1', '2', '3', '4', params)
      expect(api.gradeSubmissionWithRubric).toHaveBeenCalledWith('1', '2', '3', params)
    })

    it('passes the submissionID, assignmentID and params in the action payload', () => {
      let params = {
        '1': { comments: '', points: 10 },
      }
      let { payload } = actions.gradeSubmissionWithRubric('1', '2', '3', '4', params)
      expect(payload).toHaveProperty('submissionID', '4')
      expect(payload).toHaveProperty('assignmentID', '2')
      expect(payload).toHaveProperty('rubricAssessment', params)
    })
  })
})
