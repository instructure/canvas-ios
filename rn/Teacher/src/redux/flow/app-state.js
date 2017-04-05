// @flow

export type AsyncState = {
  +pending: number,
  +error?: ?string,
}

export type EntityRefs = Array<string>
export type AsyncRefs = AsyncState & { +refs: EntityRefs }

export type CourseState = {
  +color: string,
  +course: Course,
}

export type TabsState = AsyncState & { +tabs: Array<Tab> }

export type CourseContentState = {
  +tabs: TabsState,
  +assignmentGroups: AsyncRefs,
  +enrollments: AsyncRefs,
}

export type GradingPeriodsState = {
  [string]: {
    gradingPeriod: GradingPeriod,
    assignmentRefs: Array<string>,
  },
}

export type AssignmentState = AsyncState & {
  assignment: Assignment,
}

export type CoursesState = { [string]: CourseState & CourseContentState }
export type AssignmentGroupsState = { [string]: AssignmentGroup }
export type AssignmentsState = { [string]: AssignmentState }
export type EnrollmentsState = { [string]: Enrollment }

export type Entities = {
  +courses: CoursesState,
  +assignmentGroups: AssignmentGroupsState,
  +enrollments: EnrollmentsState,
  +assignments: AssignmentsState,
  +gradingPeriods: GradingPeriodsState,
}

export type FavoriteCoursesState = AsyncState
  & { +courseRefs: EntityRefs }

export type AppState = {
  +favoriteCourses: FavoriteCoursesState,
  +entities: Entities,
}
