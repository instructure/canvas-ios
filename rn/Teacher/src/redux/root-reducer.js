// @flow

import { combineReducers, Reducer } from 'redux'

// constituent reducers
import toys from '../modules/toys/reducer'
import type { ToyState } from '../modules/toys/reducer'
import courses from '../modules/course-list/reducer'
import type { CoursesState } from '../modules/course-list/reducer'
import tabs from '../modules/course-details/reducer'
import assignments from '../modules/assignments/reducer'
import assignmentDetails from '../modules/assignment-details/reducer'
import type { TabsState } from '../modules/course-details/reducer'

export type State = {
  toys: ToyState,
  courses: CoursesState,
  tabs: TabsState,
}

export default (combineReducers({
  toys,
  courses,
  tabs,
  assignments,
  assignmentDetails,
}): Reducer<State, any>)
