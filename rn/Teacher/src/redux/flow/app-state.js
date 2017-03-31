// @flow

export type CourseEntities = {
  +courses: CoursesState,
}

export type AssignmentGroupsEntities = {
  +assignmentGroups: AssignmentGroupsState,
}

export type GradingPeriodEntities = {
  +gradingPeriods: GradingPeriodsState,
}

export type CoursesAppState = {
  +favoriteCourses: FavoriteCoursesState,
  +entities: CourseEntities & AssignmentGroupsEntities & AssignmentDetailsState & GradingPeriodEntities,
}

export type AppState = CoursesAppState
