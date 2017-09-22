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
