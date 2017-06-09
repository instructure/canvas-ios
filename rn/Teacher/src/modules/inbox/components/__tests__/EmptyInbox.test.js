// @flow

import React from 'react'
import renderer from 'react-test-renderer'
import EmptyInbox from '../EmptyInbox'
import Images from '../../../../images'

let defaultProps = {
  image: Images.mail,
  title: 'Title',
  text: 'text',
}

describe('EmptyInbox', () => {
  it('renders correctly', () => {
    let tree = renderer.create(
      <EmptyInbox {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
