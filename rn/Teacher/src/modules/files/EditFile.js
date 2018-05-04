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

// @flow
import React from 'react'
import api from '../../canvas-api'
import EditItem from './EditItem'

export default ({
  contextID,
  context,
  deleteFile = api.deleteFile,
  file,
  fileID,
  navigator,
  onChange,
  onDelete,
  updateCourseFileUsageRights = api.updateCourseFileUsageRights,
  updateFile = api.updateFile,
}: {
  contextID?: string,
  context?: CanvasContext,
  deleteFile: typeof api.deleteFile,
  file: File,
  fileID: string,
  navigator: Navigator,
  onChange?: (File) => any,
  onDelete?: (File) => any,
  updateCourseFileUsageRights: typeof api.updateCourseFileUsageRights,
  updateFile: typeof api.updateFile,
}) =>
  <EditItem
    contextID={contextID}
    context={context}
    delete={deleteFile}
    item={file}
    itemID={fileID}
    navigator={navigator}
    onChange={onChange}
    onDelete={onDelete}
    update={updateFile}
    updateUsageRights={updateCourseFileUsageRights.bind(null, contextID || '', fileID)}
  />
