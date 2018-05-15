//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

// Tracks all async actions by their type

import { Reducer } from 'redux'
import { createAction, handleActions } from 'redux-actions'

// Helper method to know if a set of dependent async actions are pending
export function asyncChecker (state: AppState, dependencies: string[]): boolean {
  const reports = dependencies
    .map((d) => d.toString())
    .map((d) => state.asyncActions[d]).filter(a => a)
  return reports.some(r => r.pending > 0)
}

// Pass the number of seconds that needs to be elapsed for data to be refreshed
export function asyncTTLCheck (state: AppState, dependencies: string[], ttl: number): boolean {
  const reports = dependencies
    .map((d) => d.toString())
    .map((d) => state.asyncActions[d])
  // If any of the actions have never been refreshed, an update should occur
  if (reports.filter(a => a == null).length > 0) return true
  // If the actions exist, but never successfully ended, also should refresh
  if (reports.filter(a => !a.lastResolvedDate).length > 0) return true
  const oldest = reports.map(a => a.lastResolvedDate).reduce((previous, current) => {
    if (previous != null && previous < current) return previous
    return current
  })
  const diff = (new Date()) - (oldest || NaN)
  return diff > ttl
}

export let AsyncActionTracker: any = {
  pending: createAction('async-action.pending', (name: string) => {
    return { name }
  }),
  resolved: createAction('async-action.resolved', (name: string) => {
    return { name }
  }),
  rejected: createAction('async-action.rejected', (name: string, error: string) => {
    return { name, error }
  }),
}

const { pending, resolved, rejected } = AsyncActionTracker

export const asyncActions: Reducer<any, any> = handleActions({
  [pending.toString()]: (state, action) => {
    const name = action.payload.name
    const record = {
      pending: 0,
      total: 0,
      ...(state[name] || {}),
      lastError: undefined,
    }
    record.pending = record.pending + 1
    record.total = record.total + 1
    return {
      ...state,
      [name]: record,
    }
  },
  [resolved.toString()]: (state, action) => {
    const name = action.payload.name
    const record = {
      ...state[name],
      pending: state[name].pending - 1,
      lastResolvedDate: new Date(),
      lastError: undefined,
    }
    return {
      ...state,
      [name]: record,
    }
  },
  [rejected.toString()]: (state, action) => {
    const name = action.payload.name
    const lastError = action.payload.error
    const record = {
      ...state[name],
      pending: state[name].pending - 1,
      lastError,
    }
    return {
      ...state,
      [name]: record,
    }
  },
}, {})
