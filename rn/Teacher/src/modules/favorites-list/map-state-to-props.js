// @flow
import type { CoursesState } from '../course-list/props'

export default function mapStateToProps (state: any): CoursesState {
  return state.courses
}
