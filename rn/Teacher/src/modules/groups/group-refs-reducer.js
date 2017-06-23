// @flow

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import Actions from './actions'
import i18n from 'format-message'

const { refreshGroupsForCourse } = Actions

type Response = { result: { data: Array<Group> } }

const groups: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshGroupsForCourse.toString(),
  i18n('There was a problem loading the groups.'),
  ({ result }: Response) => result.data.map(group => group.id)
)

export default groups
