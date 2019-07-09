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

/* @flow */

import { shallow } from 'enzyme'
import React from 'react'
import { View, Text } from 'react-native'
import { createStore } from 'redux'
import { wrapComponentInProviders, route } from '../'
import { setSession } from '../../canvas-api/session.js'
import * as template from '../../__templates__'

describe('wrapComponentInProviders', () => {
  const store = createStore(() => ({}))

  it('renders wrapped screen with store correctly', () => {
    const session = template.session({ actAsUserID: 2 })
    setSession(session)
    const generator = () => () =>
      <View>
        <Text>Test Screen</Text>
      </View>
    const wrappedGenerator = wrapComponentInProviders('TestScreen', generator, store)
    const Wrapped = wrappedGenerator()

    let tree = shallow(<Wrapped />)
    expect(tree).toMatchSnapshot()
  })

  it('renders wrapped screen and shows the error screen when there is an error', () => {
    global.crashReporter = { recordError: jest.fn(), setString: jest.fn(), setBool: jest.fn() }
    const ErrorThrower = () => { throw new Error() }
    const generator = () => ErrorThrower
    const wrappedGenerator = wrapComponentInProviders('TestScreen', generator, store)
    const Wrapped = wrappedGenerator()

    let tree = shallow(<Wrapped />)
    try { // https://github.com/airbnb/enzyme/issues/1255
      tree.find(ErrorThrower).dive()
    } catch (err) {
      tree.instance().componentDidCatch(err)
      tree.update()
    }
    expect(global.crashReporter.recordError).toHaveBeenCalled()
    expect(tree).toMatchSnapshot()
  })
})

test('route to something that does not exist', () => {
  expect(route('garbage')).toBeUndefined()
})
