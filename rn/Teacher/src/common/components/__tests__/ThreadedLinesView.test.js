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

import 'react-native'
import React from 'react'
import ThreadedLinesView from '../ThreadedLinesView'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../__templates__/discussion'),
}

let defaultProps = {
  depth: 0,
  avatarSize: 24,
  marginRight: 8,
  reply: template.discussionReply(),
}

it('renders correctly with empty depth', () => {
  let tree = renderer.create(<ThreadedLinesView {...defaultProps} />).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with depth 1', () => {
  let props = {
    ...defaultProps,
    depth: 1,
  }
  let tree = renderer.create(<ThreadedLinesView {...props} />).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with depth 2', () => {
  let props = {
    ...defaultProps,
    depth: 2,
  }
  let tree = renderer.create(<ThreadedLinesView {...props} />).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with depth 5', () => {
  let props = {
    ...defaultProps,
    depth: 5,
  }
  let tree = renderer.create(<ThreadedLinesView {...props} />).toJSON()
  expect(tree).toMatchSnapshot()
})
