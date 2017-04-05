// @flow

import * as coursesApi from './courses'
import * as usersApi from './users'
import * as enrollmentsApi from './enrollments'
import * as submissionsApi from './submissions'
import * as assignmentsApi from '../../api/canvas-api/assignments'

type CombinedApi = $Supertype<typeof coursesApi
  & typeof usersApi
  & typeof enrollmentsApi
  & typeof submissionsApi
  & typeof assignmentsApi>

export default ({
  ...coursesApi,
  ...usersApi,
  ...enrollmentsApi,
  ...submissionsApi,
  ...assignmentsApi,
}: CombinedApi)
