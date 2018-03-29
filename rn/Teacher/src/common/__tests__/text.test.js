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

/**
 * @flow
 */

import 'react-native'
import React from 'react'
import {
  Text,
  Paragraph,
  Heading1,
  Heading2,
  TextInput,
  ModalOverlayText,
  Separated,
} from '../text'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders text correctly', () => {
  let tree = renderer.create(
    <Text />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders text with fontWeight bold', () => {
  let tree = renderer.create(
    <Text style={{ fontWeight: 'bold' }} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders text with fontWeight semibold', () => {
  let tree = renderer.create(
    <Text style={{ fontWeight: '600' }} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders heading1 correctly', () => {
  let tree = renderer.create(
    <Heading1 />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders heading2 correctly', () => {
  let tree = renderer.create(
    <Heading2 />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders textInput correctly', () => {
  let tree = renderer.create(
    <TextInput />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders paragraph correctly', () => {
  let tree = renderer.create(
    <Paragraph />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders ModalOverlayText correctly', () => {
  let tree = renderer.create(
    <ModalOverlayText />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders separated correctly', () => {
  let tree = renderer.create(
    <Separated separator={' * '} separated={['a', 'b', 'c']} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders separated with one item', () => {
  let tree = renderer.create(
    <Separated separator={' * '} separated={['a']} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
