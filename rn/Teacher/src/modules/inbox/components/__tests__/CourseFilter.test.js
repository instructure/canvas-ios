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

/* eslint-disable flowtype/require-valid-file-annotation */
import 'react-native'
import React from 'react'
import CourseFilter from '../CourseFilter'
import explore from '../../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../../__templates__/course'),
}

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
jest.mock('../../../../routing')
const mockActionSheet = jest.fn()
jest.mock('react-native/Libraries/ActionSheetIOS/ActionSheetIOS', () => ({
  showActionSheetWithOptions: mockActionSheet,
}))

let defaultCourses = [template.course(), template.course()]
let defaultProps = {
  courses: defaultCourses,
  selectedCourse: 'all',
  onClearFilter: jest.fn(),
  onSelectFilter: jest.fn(),
}

describe('CourseFilter', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders correctly', () => {
    const tree = renderer.create(
      <CourseFilter { ...defaultProps } />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders the ActionSheet', () => {
    const tree = renderer.create(
      <CourseFilter { ...defaultProps } />
    ).toJSON()
    const button = explore(tree).selectByID('inbox.filterByCourse') || {}
    button.props.onPress()
    expect(mockActionSheet).toHaveBeenCalled()
  })

  it('calls the clearFilterCallback', () => {
    let props = {
      ...defaultProps,
      selectedCourse: 0,
    }
    const tree = renderer.create(
      <CourseFilter { ...props } />
    ).toJSON()
    const button = explore(tree).selectByID('inbox.filterByCourse') || {}
    button.props.onPress()
    expect(props.onClearFilter).toHaveBeenCalled()
  })

  it('calls the updateFilterCallback', () => {
    const tree = renderer.create(
      <CourseFilter { ...defaultProps } />
    )
    const instance = tree.getInstance()
    instance.updateFilter(1)
    expect(defaultProps.onSelectFilter).toHaveBeenCalled()
  })
})
