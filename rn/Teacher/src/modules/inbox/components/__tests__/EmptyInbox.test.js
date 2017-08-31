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

import React from 'react'
import renderer from 'react-test-renderer'
import EmptyInbox from '../EmptyInbox'
import Images from '../../../../images'

let defaultProps = {
  image: Images.mail,
  title: 'Title',
  text: 'text',
}

describe('EmptyInbox', () => {
  it('renders correctly', () => {
    let tree = renderer.create(
      <EmptyInbox {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
