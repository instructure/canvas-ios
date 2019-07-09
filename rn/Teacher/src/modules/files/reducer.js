//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* @flow */

import { type Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'

const { filesUpdated, foldersUpdated, folderUpdated } = Actions

export const filesData: Reducer<any, any> = handleActions({
  [filesUpdated.toString()]: (state, { payload }) => {
    const key = `${payload.type}-${payload.id}`
    const context = state[key] || {}
    return {
      ...state,
      [key]: {
        ...context,
        [payload.path]: payload.files,
      },
    }
  },
}, {})

export const foldersData: Reducer<any, any> = handleActions({
  [foldersUpdated.toString()]: (state, { payload }) => {
    const key = `${payload.type}-${payload.id}`
    const context = state[key] || {}
    return {
      ...state,
      [key]: {
        ...context,
        [payload.path]: payload.folders,
      },
    }
  },
  [folderUpdated.toString()]: (state, { payload }) => {
    const folder = payload.folder
    const key = `${payload.type}-${payload.id}`
    const path = folder.full_name.substring(0, folder.full_name.lastIndexOf('/'))
    const context = state[key] || {}
    const contents = context[path] || []
    const index = contents.findIndex(({ id }) => id === folder.id)
    const newContents = [...contents]
    // Add it if it doesn't exist, othewise update
    if (!~index) {
      newContents.push(folder)
    } else {
      newContents[index] = folder
    }
    return {
      ...state,
      [key]: {
        ...context,
        [path]: newContents,
      },
    }
  },
}, {})
