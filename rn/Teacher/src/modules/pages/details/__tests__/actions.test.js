// @flow

import Actions from '../actions'

const template = {
  ...require('../../../../__templates__/page'),
}

describe('refreshedPage', () => {
  it('should send page and course id', () => {
    const page = template.page({ url: 'page-1' })
    const courseID = '1'
    const action = Actions.refreshedPage(page, courseID)
    expect(action).toMatchObject({
      payload: { page, courseID },
    })
  })
})
