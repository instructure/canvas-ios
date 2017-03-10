// @flow

import { combineReducers } from 'redux'

// constituent reducers
import toys from '../modules/toys/reducer'
import courses from '../modules/course-list/reducer'
import tabs from '../modules/course-details/reducer'

export default combineReducers({
  toys,
  courses,
  tabs,
})
