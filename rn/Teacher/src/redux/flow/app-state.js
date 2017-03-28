// @flow

export type CourseEntities = {
  +courses: CoursesState,
}

export type AssignmentGroupsEntities = {
  +assignmentGroups: AssignmentGroupsState,
}

export type CoursesAppState = {
  +favoriteCourses: FavoriteCoursesState,
  +entities: CourseEntities & AssignmentGroupsEntities & AssignmentDetailsState,
}

export type AppState = CoursesAppState
