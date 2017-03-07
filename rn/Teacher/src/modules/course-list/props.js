// @flow

export type CoursesState = {
  +courses: Course[],
  +pending: number,
  +error?: string,
}

export type CoursesDataProps = CoursesState

export type CoursesActionProps = {
  +refreshCourses: () => Promise<Course[]>,
}

export type CoursesProps = CoursesDataProps & CoursesActionProps

export interface AppState {
  courses: CoursesState,
}

export function stateToProps (state: AppState): CoursesDataProps {
  return state.courses
}
