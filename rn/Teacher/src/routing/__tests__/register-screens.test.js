// @flow

import { route, screenID } from '../'
import { registerScreens } from '../register-screens'
import store from '../../redux/store'

describe('app routes', () => {
  beforeAll(() => {
    registerScreens(store)
  })

  it('includes /', () => {
    expect(route('/')).toEqual({
      screen: screenID('/'),
      passProps: {},
    })
  })

  it('includes /courses', () => {
    expect(route('/courses')).toEqual({
      screen: screenID('/courses'),
      passProps: {},
    })
  })

  it('includes /course_favorites', () => {
    expect(route('/course_favorites')).toEqual({
      screen: screenID('/course_favorites'),
      passProps: {},
    })
  })

  it('includes /courses/:courseID', () => {
    expect(route('/courses/686')).toEqual({
      screen: screenID('/courses/:courseID'),
      passProps: { courseID: '686' },
    })
  })

  it('includes /courses/:courseID/user_preferences', () => {
    expect(route('/courses/686/user_preferences')).toEqual({
      screen: screenID('/courses/:courseID/user_preferences'),
      passProps: {
        courseID: '686',
      },
    })
  })

  it('includes /courses/:courseID/assignments', () => {
    expect(route('/courses/686/assignments')).toEqual({
      screen: screenID('/courses/:courseID/assignments'),
      passProps: { courseID: '686' },
    })
  })

  it('includes /courses/:courseID/assignments/:assignmentID', () => {
    expect(route('/courses/686/assignments/1')).toEqual({
      screen: screenID('/courses/:courseID/assignments/:assignmentID'),
      passProps: { courseID: '686', assignmentID: '1' },
    })
  })

  it('includes /courses/:courseID/assignments/:assignmentID/edit', () => {
    expect(route('/courses/686/assignments/1/edit')).toEqual({
      screen: screenID('/courses/:courseID/assignments/:assignmentID/edit'),
      passProps: { courseID: '686', assignmentID: '1' },
    })
  })

  it('includes /conversations', () => {
    expect(route('/conversations')).toEqual({
      screen: screenID('/conversations'),
      passProps: {},
    })
  })

  it('includes /profile', () => {
    expect(route('/profile')).toEqual({
      screen: screenID('/profile'),
      passProps: {},
    })
  })

  it('includes /beta-feedback', () => {
    expect(route('/beta-feedback')).toEqual({
      screen: screenID('/beta-feedback'),
      passProps: {},
    })
  })
})
