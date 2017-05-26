// @flow

import * as coursesApi from './courses'
import * as usersApi from './users'
import * as enrollmentsApi from './enrollments'
import * as submissionsApi from './submissions'
import * as assignmentsApi from './assignments'
import * as quizzesApi from './quizzes'
import * as assignmentGroupsApi from './assignmentGroups'
import * as discussionsApi from './discussions'

type CombinedApi = $Supertype<typeof coursesApi
  & typeof usersApi
  & typeof enrollmentsApi
  & typeof submissionsApi
  & typeof assignmentsApi
  & typeof assignmentGroupsApi
  & typeof quizzesApi
  & typeof discussionsApi>

export default ({
  ...coursesApi,
  ...usersApi,
  ...enrollmentsApi,
  ...submissionsApi,
  ...assignmentsApi,
  ...quizzesApi,
  ...assignmentGroupsApi,
  ...discussionsApi,
}: CombinedApi)
