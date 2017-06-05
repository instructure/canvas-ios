/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { default as ListActions } from './list/actions'
import i18n from 'format-message'

const { refreshAnnouncements } = ListActions

export const refs: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshAnnouncements.toString(),
  i18n('There was a problem loading the announcements.'),
  ({ result }) => result.data.map(announcement => announcement.id)
)

export const entities: Reducer<QuizzesState, any> = handleActions({
  [refreshAnnouncements.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, entity) => ({
          ...incoming,
          [entity.id]: {
            data: entity,
            pending: 0,
            error: null,
          },
        }), {})
      return { ...state, ...incoming }
    },
  }),
}, {})
