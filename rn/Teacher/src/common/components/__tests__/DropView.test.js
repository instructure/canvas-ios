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

import { shallow } from 'enzyme'
import React from 'react'
import { Platform, View } from 'react-native'
import DropView from '../DropView'

jest.mock('Platform', () => ({
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
