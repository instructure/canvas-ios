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
import * as loginApi from './login'
import * as externalTools from './external-tools'

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
  ...loginApi,
  ...externalTools,
}: CanvasApi)
