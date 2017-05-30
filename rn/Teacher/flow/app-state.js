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
  discussions: AsyncRefs,
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

export type PendingCommentState = AsyncState & {
  timestamp: string,
  localID: string, // a uuid assigned for a new comment
  commentID?: string,
  comment: SubmissionCommentParams,
}

export type PendingCommentsState = {
  // by userID since we may not have a submission
  [string]: Array<PendingCommentState>,
}

export type AssignmentContentState = {
  submissions: AsyncRefs,
  gradeableStudents: AsyncRefs,
  pendingComments: PendingCommentsState,
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
  quizSubmissions: AsyncRefs,
  submissions: AsyncRefs,
}

export type QuizSubmissionState = AsyncState & {
  data: QuizSubmission,
}

export type DiscussionState = AsyncState & {
  data: Discussion,
}

export type CourseDetailsTabSelectedRowState = {
  rowID: ?string,
}

export type CoursesState = { [string]: CourseState & CourseContentState }
export type AssignmentGroupsState = { [string]: AssignmentGroupState & AssignmentGroupContentState }
export type AssignmentsState = { [string]: AssignmentDetailState & AssignmentContentState }
export type EnrollmentsState = { [string]: Enrollment }
export type SectionsState = { [string]: Section }
export type UserProfileState = { [string]: User }
export type SubmissionsState = { [string]: SubmissionState }
export type QuizzesState = { [string]: QuizState }
export type QuizSubmissionsState = { [string]: QuizSubmissionState }
export type DiscussionsState = { [string]: DiscussionState }

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
  quizSubmissions: QuizSubmissionsState,
  discussions: DiscussionsState,
  courseDetailsTabSelectedRow: CourseDetailsTabSelectedRowState,
}

export type FavoriteCoursesState = AsyncState
  & { courseRefs: EntityRefs }

export type AppState = {
  favoriteCourses: FavoriteCoursesState,
  entities: Entities,
}
