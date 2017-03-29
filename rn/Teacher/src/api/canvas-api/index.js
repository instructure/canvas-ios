/* @flow */

import * as coursesApi from './../../api/canvas-api/courses'
import * as usersApi from '../../api/canvas-api/users'

type CombinedApi = $Supertype<typeof coursesApi & typeof usersApi>

export default ({ ...coursesApi, ...usersApi }: CombinedApi)
