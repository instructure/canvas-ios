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
    global.crashReporter = { notify: jest.fn() }
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
    expect(global.crashReporter.notify).toHaveBeenCalled()
    expect(tree).toMatchSnapshot()
  })
})

test('route to something that does not exist', () => {
  expect(route('garbage')).toBeUndefined()
})
