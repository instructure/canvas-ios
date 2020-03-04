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
import { shallow } from 'enzyme'
import React from 'react'
import CourseFavorite from '../CourseFavorite'
import * as template from '../../../../../__templates__'
import icon from '../../../../../images/inst-icons'

let defaultProps = {
  id: '1',
  course: template.course(),
  isFavorite: true,
  onPress: () => Promise.resolve(),
}

describe('CourseFavorite', () => {
  it('renders favorited as selected', () => {
    const tree = shallow(<CourseFavorite {...defaultProps} />)
    expect(tree.prop('accessibilityRole')).toBe('button')
    expect(tree.prop('accessibilityStates')).toEqual([ 'selected' ])
    expect(tree.find('Image').prop('source')).toEqual(icon('star', 'solid'))
  })

  it('renders unfavorited without selected', () => {
    const tree = shallow(<CourseFavorite {...defaultProps} isFavorite={false} />)
    expect(tree.prop('accessibilityRole')).toBe('button')
    expect(tree.prop('accessibilityStates')).toEqual([])
    expect(tree.find('Image').prop('source')).toEqual(icon('star', 'line'))
  })

  it('calls props.onPress with the course id and the toggled favorite value', () => {
    const onPress = jest.fn()
    const tree = shallow(<CourseFavorite {...defaultProps} onPress={onPress} />)
    tree.simulate('Press')
    expect(onPress).toHaveBeenCalledWith(defaultProps.course.id, false)
  })
})
