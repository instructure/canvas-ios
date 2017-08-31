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

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import ChatBubble from '../ChatBubble'

test('my chat bubbles render correctly', () => {
  let tree = renderer.create(
    <ChatBubble from="me" message="Hello, World!"/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('their chat bubbles render correctly', () => {
  let tree = renderer.create(
    <ChatBubble from="them" message="Hello, back!" />
  )
  expect(tree).toMatchSnapshot()
})
