// @flow

import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { parseErrorMessage } from '../../redux/middleware/error-handler'
import Actions from './actions'

const { refreshLTITools } = Actions

const attendanceTool = handleActions({
  [refreshLTITools.toString()]: handleAsync({
    pending: state => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, { result }: { result: { data: Array<LtiLaunchDefinition> } }) => {
      let id = null
      for (let i = 0; i < result.data.length; ++i) {
        let tool = result.data[i]
        let courseNav = tool.placements.course_navigation
        if (!courseNav) {
          continue
        }
        if (courseNav.url.includes('rollcall.instructure.com') ||
          courseNav.url.includes('rollcall.beta.instructure.com')) {
          id = tool.definition_id
          break
        }
      }

      return {
        pending: state.pending - 1,
        tabID: id ? `context_external_tool_${id}` : null,
        error: undefined,
      }
    },
    rejected: (state, { error }) => ({
      ...state,
      error: parseErrorMessage(error),
      pending: state.pending - 1,
    }),
  }),
}, { pending: 0 })

export default (attendanceTool: *)
