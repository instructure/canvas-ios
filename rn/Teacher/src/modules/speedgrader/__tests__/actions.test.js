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

import { SpeedGraderActions } from '../actions'

let api = {
  gradeSubmission: jest.fn(),
  gradeSubmissionWithRubric: jest.fn(),
}

let actions = SpeedGraderActions(api)

describe('SpeedGraderActions', () => {
  beforeEach(() => jest.clearAllMocks())

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
