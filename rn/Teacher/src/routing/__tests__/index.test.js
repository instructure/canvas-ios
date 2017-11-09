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

import { View, Text } from 'react-native'
import React from 'react'
import { wrapComponentInReduxProvider, route } from '../'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

class TestScreen extends React.Component {
  render () {
    return (<View>
              <Text>Test Screen</Text>
            </View>)
  }
}

test('renders wrapped screen with store correctly', () => {
  const generator = () => TestScreen
  const wrappedGenerator = wrapComponentInReduxProvider('TestScreen', generator, {})
  const Wrapped = wrappedGenerator()

  let tree = renderer.create(
    <Wrapped />
  )
  expect(tree.toJSON()).toMatchSnapshot()
})

test('route to something that does not exist', () => {
  try {
    route('garbage')
  } catch (error) {
    expect(error).toBeDefined()
  }
})
