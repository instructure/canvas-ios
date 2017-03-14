// @flow

import { combineReducers, Reducer } from 'redux'

// constituent reducers
import toys from '../modules/toys/reducer'
import type { ToyState } from '../modules/toys/reducer'
import courses from '../modules/course-list/reducer'
import type { CoursesState } from '../modules/course-list/reducer'
import tabs from '../modules/course-details/reducer'
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
}): Reducer<State, any>)
