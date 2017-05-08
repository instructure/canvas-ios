// @flow

import * as coursesApi from './courses'
import * as usersApi from './users'
import * as enrollmentsApi from './enrollments'
import * as submissionsApi from './submissions'
import * as assignmentsApi from './assignments'
import * as quizzesApi from './quizzes'

type CombinedApi = $Supertype<typeof coursesApi
  & typeof usersApi
  & typeof enrollmentsApi
  & typeof submissionsApi
  & typeof quizzesApi
  & typeof assignmentsApi>

export default ({
  ...coursesApi,
  ...usersApi,
  ...enrollmentsApi,
  ...submissionsApi,
  ...assignmentsApi,
  ...quizzesApi,
}: CombinedApi)
