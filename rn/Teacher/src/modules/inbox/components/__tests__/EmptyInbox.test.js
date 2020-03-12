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
import EmptyInbox from '../EmptyInbox'

let defaultProps = {
  title: 'Title',
  text: 'text',
}

describe('EmptyInbox', () => {
  it('renders correctly', () => {
    let tree = shallow(<EmptyInbox {...defaultProps} />)
    expect(tree.find('[children="Title"]').exists()).toBe(true)
    expect(tree.find('[children="text"]').exists()).toBe(true)
  })
})
