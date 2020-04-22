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

import { shallow } from 'enzyme'
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

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

describe('AddressBookToken', () => {
  it('renders', () => {
    let tree = renderer.create(
      <AddressBookToken {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders name', async () => {
    let props = {
      item: {
        id: '1',
        name: 'Eve',
      },
    }
    let tree = shallow(<AddressBookToken {...props} />)
    expect(tree.find('[testID="message-recipient.1.label"]').prop('children')).toEqual('Eve')

    props.item.pronouns = 'She/Her'
    await tree.setProps(props)
    expect(tree.find('[testID="message-recipient.1.label"]').prop('children')).toEqual('Eve (She/Her)')
  })

  it('renders with pronouns', () => {
    let props = {
      item: {
        id: '1',
        name: 'Eve',
      },
    }
    let tree = shallow(<AddressBookToken {...props} />)
    expect(tree.find('[testID="message-recipient.1.label"]').prop('children')).toEqual('Eve')
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

  it('renders delete button if canDelete', () => {
    const view = shallow(<AddressBookToken {...defaultProps} canDelete={true} />)
    const button = view.find('[testID="message-recipient.1.delete-btn"]')
    expect(button.exists()).toEqual(true)
  })

  it('does not render delete button if canDelete', () => {
    const view = shallow(<AddressBookToken {...defaultProps} canDelete={false} />)
    const button = view.find('[testID="message-recipient.1.delete-btn"]')
    expect(button.exists()).toEqual(false)
  })
})
