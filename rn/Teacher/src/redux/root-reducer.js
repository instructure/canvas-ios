// @flow

import { combineReducers, Reducer } from 'redux'
import { courses } from '../modules/courses/courses-reducer'
import { favoriteCourses } from '../modules/courses/favorites/favorite-courses-reducer'
import assignments from '../modules/assignments/reducer'
import assignmentDetails from '../modules/assignment-details/reducer'

const entities = combineReducers({
  courses,
})

export default (combineReducers({
  assignments,
  assignmentDetails,
  favoriteCourses,
  entities,
}): Reducer<AppState, any>)
