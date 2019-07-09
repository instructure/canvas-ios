//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import HomeTabRow from '../HomeTabRow'

const template = {
  ...require('../../../__templates__/tab'),
  ...require('../../../__templates__/course'),
}

const defaultProps = {
  tab: template.tab(),
  course: template.course({ 'default_view': 'assignments' }),
  courseColor: 'white',
  onPress: () => {},
}

describe('HomeTabRow', () => {
  it('renders correctly', () => {
    const tree = shallow(<HomeTabRow {...defaultProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders correctly for each type', () => {
    const types = ['assignments', 'feed', 'wiki', 'modules', 'syllabus', 'whatisthis']
    types.forEach((type) => {
      const course = template.course({ 'default_view': type })
      const tree = shallow(<HomeTabRow {...defaultProps} course={course} />)
      expect(tree).toMatchSnapshot()
    })
  })

  it('can be selected', () => {
    const tree = shallow(<HomeTabRow {...defaultProps} selected />)
    expect(tree).toMatchSnapshot()
  })

  it('can be pressed', () => {
    const onPressed = jest.fn()
    const props = {
      ...defaultProps,
      onPress: onPressed,
    }

    const tree = shallow(<HomeTabRow {...props} />)
    expect(tree).toMatchSnapshot()
    tree.find('FeatureRow').simulate('press')
    expect(onPressed).toHaveBeenCalledTimes(1)
  })
})
