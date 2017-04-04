/* @flow */

import * as coursesApi from './../../api/canvas-api/courses'
import * as usersApi from '../../api/canvas-api/users'
import * as assignmentsApi from '../../api/canvas-api/assignments'

type CombinedApi = $Supertype<typeof coursesApi & typeof usersApi & typeof assignmentsApi>

export default ({ ...coursesApi, ...usersApi, ...assignmentsApi }: CombinedApi)
