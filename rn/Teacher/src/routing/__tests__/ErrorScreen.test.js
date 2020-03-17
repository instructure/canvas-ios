//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import * as template from '../../__templates__'
import ErrorScreen from '../ErrorScreen'

describe('ErrorScreen', () => {
  it('renders an error', () => {
    const tree = shallow(<ErrorScreen navigator={template.navigator()} />)
    expect(tree.find('Text[children="Whoops!"]').exists()).toBe(true)
  })

  it('sets nav to dark unless in a modal', () => {
    const tree = shallow(<ErrorScreen navigator={template.navigator()} />)
    expect(tree.find('Screen').prop('navBarStyle')).toBe('global')
    tree.setProps({ navigator: template.navigator({ isModal: true }) })
    expect(tree.find('Screen').prop('navBarStyle')).toBe('modal')
  })
})
