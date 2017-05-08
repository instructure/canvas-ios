// @flow

export type AsyncState = {
  pending: number,
  error?: ?string,
}

export type EntityRefs = Array<string>
export type AsyncRefs = AsyncState & { refs: EntityRefs }

export type CourseState = AsyncState & {
  color: string,
  course: Course,
}

export type TabsState = AsyncState & { tabs: Array<Tab> }

export type CourseContentState = {
  tabs: TabsState,
  assignmentGroups: AsyncRefs,
  enrollments: AsyncRefs,
  quizzes: AsyncRefs,
}

export type GradingPeriodsState = {
  [string]: {
    gradingPeriod: GradingPeriod,
    assignmentRefs: Array<string>,
  },
}

export type AssignmentGroupContentState = {
  assignmentRefs: EntityRefs,
}

export type AssignmentGroupState = {
  group: AssignmentGroup,
}

export type AssignmentContentState = {
  submissions: AsyncRefs,
}

export type AssignmentDetailState = AsyncState & {
  data: Assignment,
}

export type SubmissionState = AsyncState & {
  submission: SubmissionWithHistory,
  rubricGradePending: boolean,
  selectedIndex: ?number,
  selectedAttachmentIndex: ?number,
}

export type QuizState = AsyncState & {
  data: Quiz,
}

export type CoursesState = { [string]: CourseState & CourseContentState }
export type AssignmentGroupsState = { [string]: AssignmentGroupState & AssignmentGroupContentState }
export type AssignmentsState = { [string]: AssignmentDetailState & AssignmentContentState }
export type EnrollmentsState = { [string]: Enrollment }
export type SectionsState = { [string]: Section }
export type UserProfileState = { [string]: User }
export type SubmissionsState = { [string]: SubmissionState }
export type QuizzesState = { [string]: QuizState }

export type Entities = {
  courses: CoursesState,
  assignmentGroups: AssignmentGroupsState,
  enrollments: EnrollmentsState,
  assignments: AssignmentsState,
  gradingPeriods: GradingPeriodsState,
  sections: SectionsState,
  users: UserProfileState,
  submissions: SubmissionsState,
  quizzes: QuizzesState,
}

export type FavoriteCoursesState = AsyncState
  & { courseRefs: EntityRefs }

export type Snap = 0 | 1 | 2
export type SnapState = {
  currentSnap: Snap,
}

export type AppState = {
  drawer: SnapState,
  favoriteCourses: FavoriteCoursesState,
  entities: Entities,
}
