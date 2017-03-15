// @flow

import { route, routes, screenID } from '../'
import { registerScreens } from '../register-screens'
import store from '../../redux/store'

describe('app routes', () => {
  beforeAll(() => {
    registerScreens(store)
  })

  // this will help us remember to test our routes
  it('has all routes declared', () => {
    expect(routes.length).toEqual(9)
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

  it('includes /profile', () => {
    expect(route('/profile')).toEqual({
      screen: screenID('/profile'),
      passProps: {},
    })
  })

  it('includes /default', () => {
    expect(route('/default')).toEqual({
      screen: screenID('/default'),
      passProps: {},
    })
  })

  it('includes /toys/legosets', () => {
    expect(route('/toys/legosets')).toEqual({
      screen: screenID('/toys/legosets'),
      passProps: {},
    })
  })

  it('includes /toys/actionfigures', () => {
    expect(route('/toys/actionfigures')).toEqual({
      screen: screenID('/toys/actionfigures'),
      passProps: {},
    })
  })
})
