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
import { Platform, View } from 'react-native'
import DropView from '../DropView'

jest.mock('react-native/Libraries/Utilities/Platform', () => ({
  OS: 'ios',
  Version: '11.2',
}))

describe('DropView', () => {
  const warn = console.warn
  beforeEach(() => {
    console.warn = jest.fn()
  })
  afterEach(() => {
    console.warn = warn
  })

  it('renders a native dropview on ios 11 and above', () => {
    // $FlowFixMe
    Platform.Version = '11.2.1'
    const tree = shallow(<DropView><View /></DropView>)
    expect(tree).toMatchSnapshot()
    expect(console.warn).not.toHaveBeenCalled()
  })

  it('warns and renders a normal view on other versions', () => {
    // $FlowFixMe
    Platform.Version = '10.3.1'
    const tree = shallow(<DropView />)
    expect(tree).toMatchSnapshot()
    expect(tree.type()).toBe(View)
    expect(console.warn).toHaveBeenCalledWith('DropView can only be used on iOS 11+')
  })
})
