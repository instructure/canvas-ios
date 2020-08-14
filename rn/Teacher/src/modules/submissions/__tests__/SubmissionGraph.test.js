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

import { shallow } from 'enzyme'
import React from 'react'
import SubmissionGraph from '../SubmissionGraph'

const defaultProps: { [string]: any } = {
  label: 'foo',
  current: 25,
  total: 100,
  pending: false,
}

describe('SubmissionGraph', () => {
  it('renders', () => {
    let tree = shallow(
      <SubmissionGraph {...defaultProps} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders 0 on graph', () => {
    let tree = shallow(
      <SubmissionGraph {...defaultProps} current={0} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders undefined label', () => {
    let tree = shallow(
      <SubmissionGraph {...defaultProps} label={undefined} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('updates progress', () => {
    const props = {
      ...defaultProps,
      current: 0,
      total: 100,
      testID: 'graded',
    }
    const tree = shallow(
      <SubmissionGraph {...props} />
    )
    tree.setProps({ current: 50, total: 100, pending: false })
    const circle = tree.find('[testID="submissions.submission-graph.graded-progress-view"]')
    expect(circle.prop('progress')).toEqual(0.5)
  })
})
