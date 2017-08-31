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
