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

import React from 'react'
import AutoGrowingTextInput from '../AutoGrowingTextInput'
import renderer from 'react-test-renderer'

let defaultProps = {
  defaultHeight: 54,
  onContentSizeChange: jest.fn(),
}

describe('AutoGrowingTextInput', () => {
  beforeEach(() => jest.clearAllMocks())
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
