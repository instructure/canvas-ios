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

jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('../../../../routing')
const mockActionSheet = jest.fn()
jest.mock('ActionSheetIOS', () => ({
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
    jest.resetAllMocks()
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
