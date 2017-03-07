// @flow

import { combineReducers } from 'redux'

// constituent reducers
import toys from '../modules/toys/reducer'
import coursesReducer from '../modules/course-list/reducer'

export default combineReducers({
  toys,
  courses: coursesReducer,
})
