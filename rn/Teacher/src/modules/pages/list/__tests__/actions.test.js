// @flow

import Actions from '../actions'

const template = {
  ...require('../../../../__templates__/page'),
}

describe('refreshedPages', () => {
  it('should send pages and course id', () => {
    const pages = [template.page({ url: 'page-1' }), template.page({ url: 'page-2' })]
    const courseID = '1'
    const action = Actions.refreshedPages(pages, courseID)
    expect(action).toMatchObject({
      payload: { pages, courseID },
    })
  })
})
