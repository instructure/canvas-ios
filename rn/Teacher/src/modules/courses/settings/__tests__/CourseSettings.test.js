// @flow

import React from 'react'
import { CourseSettings } from '../CourseSettings.js'
import * as courseTemplates from '../../../../api/canvas-api/__templates__/course'
import * as navigatorTemplates from '../../../../__templates__/react-native-navigation'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import { Alert } from 'react-native'
import { Navigation } from 'react-native-navigation'

import renderer from 'react-test-renderer'

jest
  .mock('PickerIOS', () => require('../../../../__mocks__/PickerIOS').default)
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
  .mock('react-native-navigation', () => ({
    Navigation: {
      dismissAllModals: jest.fn(),
    },
  }))

let templates = { ...courseTemplates, ...navigatorTemplates }

let defaultProps = {
  navigator: templates.navigator(),
  course: templates.course(),
  color: '#333',
  updateCourse: jest.fn(() => { console.log('default') }),
}

function toggleHomePicker (component: *) {
  const homeRow: any = explore(component.toJSON()).selectByID('courses.settings.toggle-home-picker')
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
    expect(defaultProps.navigator.setTitle).toHaveBeenCalledWith({
      title: 'Course Settings',
    })
    expect(defaultProps.navigator.setOnNavigatorEvent).toHaveBeenCalled()
  })

  it('renders a modal activity when saving', () => {
    let onNavigatorEvent = () => {}
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )

    onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

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
    let onNavigatorEvent = () => {}
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )
    let updateCourse = jest.fn(() => {
      setProps(component, { pending: 0, error: 'error' })
    })
    component.update(<CourseSettings {...props} updateCourse={updateCourse} />)

    onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

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
    let onNavigatorEvent = () => {}
    const props = {
      ...defaultProps,
      updateCourse: jest.fn(),
      navigator: templates.navigator({
        setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )
    toggleHomePicker(component)
    let tree = component.toJSON()
    let nameField = explore(tree).selectByID('nameInput') || {}
    nameField.props.onChangeText('React Native FTW')
    let homePicker = explore(tree).selectByID('homePicker') || {}
    homePicker.props.onValueChange('syllabus')

    onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

    let updated = {
      ...props.course,
      name: 'React Native FTW',
      default_view: 'syllabus',
    }
    expect(props.updateCourse).toHaveBeenCalledWith(updated, props.course)
  })

  it('dismisses modal on done after course updates', () => {
    let onNavigatorEvent = () => {}
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
      }),
    }
    let component = renderer.create(
      <CourseSettings {...props} />
    )
    let updateCourse = jest.fn(() => {
      setProps(component, { pending: 0 })
    })
    component.update(<CourseSettings {...props} updateCourse={updateCourse} />)

    onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

    expect(Navigation.dismissAllModals).toHaveBeenCalled()
  })

  it('dismisses on cancel', () => {
    let onNavigatorEvent = () => {}
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismissModal: jest.fn(),
        setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
      }),
    }
    renderer.create(
      <CourseSettings {...props} />
    )

    onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'cancel',
    })

    expect(props.navigator.dismissModal).toHaveBeenCalled()
  })

  it('does not dismiss if there was an error', () => {
    let onNavigatorEvent = () => {}
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismissModal: jest.fn(),
        setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
      }),
    }

    let component = renderer.create(
      <CourseSettings {...props} />
    )
    let updateCourse = jest.fn(() => {
      setProps(component, { pending: 0, error: 'there was an error' })
    })
    component.update(<CourseSettings {...props} updateCourse={updateCourse} />)

    onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

    expect(Navigation.dismissAllModals).not.toHaveBeenCalled()
  })

  it('shows correct label based on course home', () => {
    const props = {
      ...defaultProps,
      course: templates.course({ default_view: 'wiki' }),
    }
    let tree = renderer.create(
      <CourseSettings {...props } />
    ).toJSON()

    let label = explore(tree).selectByID('homePageLabel') || {}
    expect(label.children[0]).toEqual('Pages Front Page')

    props.course.default_view = 'feed'
    tree = renderer.create(
      <CourseSettings {...props } />
    ).toJSON()

    label = explore(tree).selectByID('homePageLabel') || {}
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
