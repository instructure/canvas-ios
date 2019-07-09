//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

export type AsyncState = {
  pending: number,
  error?: ?string,
  next?: Function,
}

export type EntityRefs = Array<string>
export type AsyncRefs = AsyncState & { refs: EntityRefs }

export type CourseState = AsyncState & {
  color: string,
  course: Course,
}

export type TabsState = AsyncState & { tabs: Array<Tab> }
export type AttendanceToolState = { tabID?: ?string } & AsyncState

export type CourseContentState = {
  tabs: TabsState,
  assignmentGroups: AsyncRefs,
  enrollments: AsyncRefs,
  quizzes: AsyncRefs,
  discussions: AsyncRefs & PendingNewDiscussionState,
  announcements: AsyncRefs,
  groups: AsyncRefs,
  attendanceTool: AttendanceToolState,
  gradingPeriods: AsyncRefs,
  permissions: ?{ [string]: boolean },
  enabledFeatures: string[],
  dashboardPosition: ?number,
  settings: ?CourseSettings,
}

export type GroupState = AsyncState & {
  group: Group,
  color: ?string,
  permissions: ?{ [string]: boolean },
}

export type GroupContentState = {
  discussions?: AsyncRefs,
  announcements?: AsyncRefs,
}

export type GradingPeriodsState = {
  [string]: {
    gradingPeriod: GradingPeriod,
    assignmentRefs: Array<string>,
  },
}

export type AccountNotificationState = {
  pending: number,
  list: AccountNotification[],
  closing: string[],
  error: string,
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
  mediaComment?: MediaComment,
}

export type PendingCommentsState = {
  // by userID since we may not have a submission
  [string]: Array<PendingCommentState>,
}

export type AsyncActionState = {
  pending: number,
  total: number,
  lastResolvedDate?: date,
  lastError?: ?string,
}

export type SubmissionSummaryState = {
  data: SubmissionSummary,
  pending: number,
  error: ?string,
}

export type AssignmentContentState = {
  submissions: AsyncRefs,
  submissionSummary: SubmissionSummaryState,
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
  lastGradedAt: ?number,
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
  replies?: {
    new?: AsyncState,
    edit?: AsyncState,
  },
  unread_entries: string[],
  entry_ratings: { [string]: number },
  initialPostRequired?: boolean,
  isAnnouncement?: boolean,
}

export type PendingDiscussionReply = {
  localIndexPath: number[],
  data: DiscussionReply,
}

export type PendingDiscussionReplyState = {
  pendingReplies: PendingDiscussionReply[],
}

export type CourseDetailsTabSelectedRowState = {
  rowID: ?string,
}

export type CoursesState = { [string]: CourseState & CourseContentState }
export type GroupsState = { [string]: GroupState & GroupContentState }
export type AssignmentGroupsState = { [string]: AssignmentGroupState & AssignmentGroupContentState }
export type AssignmentsState = { [string]: AssignmentDetailState & AssignmentContentState }
export type EnrollmentsState = { [string]: Enrollment }
export type SectionsState = { [string]: Section }
export type UserProfileState = { [string]: User }
export type SubmissionsState = { [string]: SubmissionState }
export type QuizzesState = { [string]: QuizState }
export type QuizSubmissionsState = { [string]: QuizSubmissionState }
export type DiscussionsState = { [string]: DiscussionState & PendingDiscussionReplyState }

export type Entities = {
  accountNotifications: AccountNotificationState,
  courses: CoursesState,
  groups: GroupsState,
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

export type FavoriteGroupsState = AsyncState
  & { groupRefs: EntityRefs, userHasFavoriteGroups: boolean }

export type ConversationState = AsyncState & {
  data: Conversation,
}
export type InboxState = {
  conversations: { [string]: ConversationState },
  selectedScope: InboxScope,
  all: AsyncRefs,
  unread: AsyncRefs,
  starred: AsyncRefs,
  sent: AsyncRefs,
  archived: AsyncRefs,
}

export type AppState = {
  favoriteCourses: FavoriteCoursesState,
  favoriteGroups: FavoriteGroupsState,
  entities: Entities,
  inbox: InboxState,
  asyncActions: { [string]: AsyncActionState },
  userInfo: UserInfo,
}

export type UserInfo = {
  canActAsUser: boolean,
  showsGradesOnCourseCards: boolean,
  externalTools: ExternalToolLaunchDefinitionGlobalNavigationItem[],
  helpLinks?: HelpLinks,
  userSettings: UserSettings,
}

// I moved this to the bottom because something with it is making vscode syntax highlighting stop working in this file
export type PendingNewDiscussionState = {
  new?: AsyncState & { id?: ?string },
}
