// @flow

import React from 'react'
import renderer from 'react-test-renderer'

import AddressBookToken from '../AddressBookToken'
import explore from '../../../../../test/helpers/explore'

let defaultProps = {
  item: {
    id: '1',
    name: 'Donald Trump',
  },
  delete: jest.fn(),
}

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

describe('AddressBookToken', () => {
  it('renders', () => {
    let tree = renderer.create(
      <AddressBookToken {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with avatar url', () => {
    const item = {
      ...defaultProps.item,
      avatar_url: 'http://www.fillmurray.com/100/100',
    }
    let tree = renderer.create(
      <AddressBookToken {...defaultProps} item={item} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('calls delete when delete button tapped', () => {
    let tree = renderer.create(
      <AddressBookToken {...defaultProps} />
    )

    let button = explore(tree.toJSON()).selectByID('message-recipient.1.delete-btn') || {}
    button.props.onPress()

    expect(tree.getInstance().props.delete).toHaveBeenCalledWith(defaultProps.item.id)
  })
})
