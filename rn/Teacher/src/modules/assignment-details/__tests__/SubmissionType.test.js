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
import SubmissionType from '../components/SubmissionType'
import renderer from 'react-test-renderer'

const defaultProps = {
  data: ['foo', 'bar'],
}

test('render', () => {
  let tree = renderer.create(
    <SubmissionType {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 types', () => {
  defaultProps.data = []
  let tree = renderer.create(
    <SubmissionType {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render single type', () => {
  defaultProps.data = ['foo']
  let tree = renderer.create(
    <SubmissionType {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render no data', () => {
  let props = {
    ...defaultProps,
    data: null,
  }
  let tree = renderer.create(
    <SubmissionType {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
