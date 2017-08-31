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
import AutoGrowingTextInput from '../AutoGrowingTextInput'
import renderer from 'react-test-renderer'

let defaultProps = {
  defaultHeight: 54,
  onContentSizeChange: jest.fn(),
}

describe('AutoGrowingTextInput', () => {
  beforeEach(() => jest.resetAllMocks())
  it('renders', () => {
    let tree = renderer.create(
      <AutoGrowingTextInput {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('adjusts the height when content size is updated', () => {
    let tree = renderer.create(
      <AutoGrowingTextInput {...defaultProps} />
    )

    let event = { nativeEvent: { contentSize: { height: 100 } } }

    tree.getInstance().updateContentSize(event)
    expect(tree.toJSON()).toMatchSnapshot()
    expect(defaultProps.onContentSizeChange).toHaveBeenCalledWith(event)
  })
})
