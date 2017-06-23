// @flow

import * as coursesApi from './courses'
import * as usersApi from './users'
import * as enrollmentsApi from './enrollments'
import * as submissionsApi from './submissions'
import * as assignmentsApi from './assignments'
import * as quizzesApi from './quizzes'
import * as assignmentGroupsApi from './assignmentGroups'
import * as discussionsApi from './discussions'
import * as conversationApi from './conversations'
import * as groupsApi from './groups'

type CombinedApi = $Supertype<typeof coursesApi
  & typeof usersApi
  & typeof enrollmentsApi
  & typeof groupsApi
  & typeof submissionsApi
  & typeof assignmentsApi
  & typeof assignmentGroupsApi
  & typeof quizzesApi
  & typeof discussionsApi
  & typeof conversationApi>

export default ({
  ...coursesApi,
  ...usersApi,
  ...enrollmentsApi,
  ...groupsApi,
  ...submissionsApi,
  ...assignmentsApi,
  ...quizzesApi,
  ...assignmentGroupsApi,
  ...discussionsApi,
  ...conversationApi,
}: CombinedApi)
