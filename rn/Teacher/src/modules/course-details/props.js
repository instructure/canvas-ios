// @flow

export type TabsState = {
  +tabs: Tab[],
  +courseColors: CustomColors,
  +pending: number,
  +error?: string,
}

export type TabsDataProps = TabsState

export type TabsActionProps = {
  +refreshTabs: () => Promise<Tab[]>,
}

export type TabsProps = TabsDataProps & TabsActionProps

type CoursesState = {
  +courses: Course[],
}

export interface AppState {
  courses: CoursesState,
  tabs: TabsState,
}

type RoutingParams = {
  courseID: string,
}

export function stateToProps (state: AppState, ownProps: RoutingParams): TabsDataProps {
  let course = state.courses.courses.find((course) => {
    return course.id.toString() === ownProps.courseID
  })
  if (!course) {
    throw new Error('A Course with id ' + ownProps.courseID + ' was expected')
  }
  return {
    course,
    ...state.tabs,
  }
}
