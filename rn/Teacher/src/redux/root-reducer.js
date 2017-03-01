// @flow

import { combineReducers } from 'redux'

// constituent reducers
import toys from '../modules/toys/reducer'

export default combineReducers({
  toys,
})
