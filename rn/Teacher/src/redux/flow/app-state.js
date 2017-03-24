// @flow

export type CourseEntities = {
  +courses: CoursesState,
}

export type CoursesAppState = {
  +favoriteCourses: FavoriteCoursesState,
  +entities: CourseEntities,
}

export type AppState = CoursesAppState
