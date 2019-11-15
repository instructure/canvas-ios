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
    <Heading2 />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders heading2 correctly', () => {
  let tree = renderer.create(
    <Heading1 />
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
