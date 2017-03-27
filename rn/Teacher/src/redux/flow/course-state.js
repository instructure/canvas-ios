// @flow

export type CourseState = {
  +color?: ?string,
  +course: Course,
}

export type TabsState = AsyncState & {
  +tabs: Array<Tab>,
}

export type AssignmentGroupsRefState = AsyncState & {
  refs: EntityRefs,
}

export type CourseContentState = {
  +tabs: tabs,
  +assignmentGroups: AssignmentGroupsRefState,
}

export type CoursesState = {
  [courseID: string]: CourseState & CourseContentState,
}

export type FavoriteCoursesState = AsyncState & {
  +courseRefs: EntityRefs,
}

export type CourseAction = {
  +payload: { +courseID: string },
}
