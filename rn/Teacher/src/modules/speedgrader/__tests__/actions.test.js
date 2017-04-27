// @flow

import { SpeedGraderActions } from '../actions'

let api = {
  gradeSubmission: jest.fn(),
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
    })
  })

  describe('selectSubmissionFromHistory', () => {
    it('passes the submissionID and index in the action payload', () => {
      let { payload } = actions.selectSubmissionFromHistory('1', 2)
      expect(payload).toHaveProperty('submissionID', '1')
      expect(payload).toHaveProperty('index', 2)
    })
  })
})
