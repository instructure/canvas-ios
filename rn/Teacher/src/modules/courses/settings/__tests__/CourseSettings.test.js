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

import { shallow } from 'enzyme'
import React from 'react'
import { CourseSettings } from '../CourseSettings'
import * as templates from '../../../../__templates__'
import { Alert } from 'react-native'

jest
  .mock('react-native/Libraries/LayoutAnimation/LayoutAnimation', () => ({
    create: jest.fn(),
    configureNext: jest.fn(),
    Types: { linear: null },
    Properties: { opacity: null },
  }))
  .mock('react-native/Libraries/Alert/Alert', () => ({
    alert: jest.fn(),
  }))
  .useFakeTimers()

const defaultProps = {
  navigator: templates.navigator(),
  course: templates.course(),
  color: '#333',
  updateCourse: jest.fn(),
  pending: 0,
  error: null,
}

function toggleHomePicker (tree: *) {
  tree.find('[testID="course-settings.toggle-home-picker"]').simulate('Press')
}

describe('CourseSettings', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders', () => {
    const tree = shallow(<CourseSettings { ...defaultProps } />)
    expect(tree).toMatchSnapshot()
  })

  it('renders a modal activity when saving', () => {
    const tree = shallow(<CourseSettings {...defaultProps} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    tree.update()
    expect(tree).toMatchSnapshot()
  })

  it('presents error alert', () => {
    const tree = shallow(<CourseSettings {...defaultProps} />)
    tree.setProps({ error: 'error' })
    jest.runAllTimers()
    expect(Alert.alert).toHaveBeenCalled()
  })

  it('dismisses modal activity upon save error', () => {
    const tree = shallow(<CourseSettings {...defaultProps} />)
    const updateCourse = jest.fn(() => {
      tree.setProps({ pending: 0, error: 'error' })
    })
    tree.setProps({ updateCourse })
    tree.find('Screen').prop('rightBarButtons')[0].action()
    tree.update()
    expect(tree).toMatchSnapshot()
  })

  it('shows home view picker when home row tapped', () => {
    const tree = shallow(<CourseSettings {...defaultProps} />)
    toggleHomePicker(tree)
    expect(tree).toMatchSnapshot()
  })

  it('calls update with new course values on done', () => {
    const tree = shallow(<CourseSettings {...defaultProps} />)
    toggleHomePicker(tree)
    tree.find('[testID="course-settings.name-input-textbox"]')
      .simulate('ChangeText', 'React Native FTW')
    tree.find('[testID="course-settings.home-picker"]')
      .simulate('ValueChange', 'syllabus')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    tree.update()

    let updated = {
      ...defaultProps.course,
      name: 'React Native FTW',
      default_view: 'syllabus',
    }
    expect(defaultProps.updateCourse).toHaveBeenCalledWith(updated, defaultProps.course)
  })

  it('dismisses modal on done after course updates', () => {
    const tree = shallow(<CourseSettings {...defaultProps} />)
    let updateCourse = jest.fn(() => tree.setProps({ pending: 0 }))
    tree.setProps({ updateCourse })
    tree.find('Screen').prop('rightBarButtons')[0].action()
    tree.update()
    expect(defaultProps.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('does not dismiss if there was an error', () => {
    const tree = shallow(<CourseSettings {...defaultProps} />)
    let updateCourse = jest.fn(() => tree.setProps({ pending: 0, error: 'there was an error' }))
    tree.setProps({ updateCourse })
    tree.find('Screen').prop('rightBarButtons')[0].action()
    tree.update()
    expect(defaultProps.navigator.dismissAllModals).not.toHaveBeenCalled()
  })

  it('shows correct label based on course home', () => {
    const tree = shallow(
      <CourseSettings
        {...defaultProps }
        course={templates.course({ default_view: 'wiki' })}
      />
    )
    let label = tree.find('[testID="course-settings.home-page-lbl"]')
    expect(label.prop('children')).toEqual('Pages Front Page')

    tree.find('[testID="course-settings.toggle-home-picker"]').simulate('Press')
    tree.find('[testID="course-settings.home-picker"]').simulate('ValueChange', 'feed')

    label = tree.find('[testID="course-settings.home-page-lbl"]')
    expect(label.prop('children')).toEqual('Course Activity Stream')
  })

  it('renders with image url', () => {
    const course = templates.course({ image_download_url: 'http://www.fillmurray.com/100/100' })
    expect(
      shallow(<CourseSettings {...defaultProps} course={course} />)
    ).toMatchSnapshot()
  })

  it('renders without image url', () => {
    const course = templates.course({ image_download_url: null })
    expect(
      shallow(<CourseSettings {...defaultProps} course={course} />)
    ).toMatchSnapshot()
  })

  it('renders with empty image url', () => {
    const course = templates.course({ image_download_url: '' })
    expect(
      shallow(<CourseSettings {...defaultProps} course={course} />)
    ).toMatchSnapshot()
  })
})
