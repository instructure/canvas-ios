// @flow

import { SpeedgraderActions } from '../actions'

let api = {
  gradeSubmission: jest.fn(),
}

let actions = SpeedgraderActions(api)

describe('SpeedgraderActions', () => {
  beforeEach(() => jest.resetAllMocks())

  describe('excuseAssignment', () => {
    it('calls gradeSubmission with the correct arguments', () => {
      actions.excuseAssignment('1', '2', '3', '4')
      expect(api.gradeSubmission).toHaveBeenCalledWith('1', '2', '3', { excuse: true })
    })

    it('passes the submissionID in the action payload', () => {
      let { payload } = actions.excuseAssignment('1', '2', '3', '4')
      expect(payload).toHaveProperty('submissionID', '4')
    })
  })
})
