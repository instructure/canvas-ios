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

import React from 'react'
import { CourseSettings } from '../CourseSettings.js'
import * as courseTemplates from '../../../../__templates__/course'
import * as navigatorTemplates from '../../../../__templates__/helm'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import { Alert } from 'react-native'

import renderer from 'react-test-renderer'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('LayoutAnimation', () => ({
    create: jest.fn(),
    configureNext: jest.fn(),
    Types: { linear: null },
    Properties: { opacity: null },
  }))
  .mock('Alert', () => ({
    alert: jest.fn(),
  }))

let templates = { ...courseTemplates, ...navigatorTemplates }

let defaultProps = {
  navigator: templates.navigator(),
  course: templates.course(),
  color: '#333',
  updateCourse: jest.fn(() => { console.log('default') }),
}

function toggleHomePicker (component: *) {
  const homeRow: any = explore(component.toJSON()).selectByID('course-settings.toggle-home-picker')
  homeRow.props.onPress()
}

describe('CourseSettings', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('renders', () => {
    let tree = renderer.create(
      <CourseSettings { ...defaultProps } />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders a modal activity when saving', () => {
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        show: jest.fn(),
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )

    component.getInstance().done()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('presents error alert', () => {
    jest.useFakeTimers()
    let component = renderer.create(
      <CourseSettings {...defaultProps} />
    )

    setProps(component, { error: 'error' })
    jest.runAllTimers()

    expect(Alert.alert).toHaveBeenCalled()
  })

  it('dismisses modal activity upon save error', () => {
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismiss: jest.fn(),
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )
    let updateCourse = jest.fn(() => {
      setProps(component, { pending: 0, error: 'error' })
    })
    component.update(<CourseSettings {...props} updateCourse={updateCourse} />)
    component.getInstance().done()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('shows home view picker when home row tapped', () => {
    let component = renderer.create(
      <CourseSettings {...defaultProps} />
    )

    toggleHomePicker(component)

    expect(component.toJSON()).toMatchSnapshot()
  })

  it('calls update with new course values on done', () => {
    const props = {
      ...defaultProps,
      updateCourse: jest.fn(),
      navigator: templates.navigator({
        dismiss: jest.fn(),
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )
    toggleHomePicker(component)
    let tree = component.toJSON()
    let nameField = explore(tree).selectByID('course-settings.name-input-textbox') || {}
    nameField.props.onChangeText('React Native FTW')
    let homePicker = explore(tree).selectByID('course-settings.home-picker') || {}
    homePicker.props.onValueChange('syllabus')

    component.getInstance().done()

    let updated = {
      ...props.course,
      name: 'React Native FTW',
      default_view: 'syllabus',
    }
    expect(props.updateCourse).toHaveBeenCalledWith(updated, props.course)
  })

  it('dismisses modal on done after course updates', () => {
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismissAllModals: jest.fn(),
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )
    let updateCourse = jest.fn(() => {
      setProps(component, { pending: 0 })
    })
    component.update(<CourseSettings {...props} updateCourse={updateCourse} />)
    component.getInstance().done()
    expect(props.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('does not dismiss if there was an error', () => {
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismissAllModals: jest.fn(),
      }),
    }

    let component = renderer.create(
      <CourseSettings {...props} />
    )
    let updateCourse = jest.fn(() => {
      setProps(component, { pending: 0, error: 'there was an error' })
    })
    component.update(<CourseSettings {...props} updateCourse={updateCourse} />)
    component.getInstance().done()
    expect(props.navigator.dismissAllModals).not.toHaveBeenCalled()
  })

  it('shows correct label based on course home', () => {
    const props = {
      ...defaultProps,
      course: templates.course({ default_view: 'wiki' }),
    }
    let tree = renderer.create(
      <CourseSettings {...props } />
    ).toJSON()

    let label = explore(tree).selectByID('course-settings.home-page-lbl') || {}
    expect(label.children[0]).toEqual('Pages Front Page')

    props.course.default_view = 'feed'
    tree = renderer.create(
      <CourseSettings {...props } />
    ).toJSON()

    label = explore(tree).selectByID('course-settings.home-page-lbl') || {}
    expect(label.children[0]).toEqual('Course Activity Stream')
  })

  it('renders with image url', () => {
    let course = courseTemplates.course({ image_download_url: 'http://www.fillmurray.com/100/100' })
    expect(
      renderer.create(
        <CourseSettings {...defaultProps} course={course} />
      ).toJSON()
    ).toMatchSnapshot()
  })

  it('renders without image url', () => {
    let course = courseTemplates.course({ image_download_url: null })
    expect(
      renderer.create(
        <CourseSettings {...defaultProps} course={course} />
      ).toJSON()
    ).toMatchSnapshot()
  })

  it('renders with empty image url', () => {
    let course = courseTemplates.course({ image_download_url: '' })
    expect(
      renderer.create(
        <CourseSettings {...defaultProps} course={course} />
      ).toJSON()
    ).toMatchSnapshot()
  })
})
