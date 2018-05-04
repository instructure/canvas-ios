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
  deleteFolder = api.deleteFolder,
  folder,
  folderID,
  navigator,
  onChange,
  onDelete,
  updateFolder = api.updateFolder,
}: {
  deleteFolder: typeof api.deleteFolder,
  folder: Folder,
  folderID: string,
  navigator: Navigator,
  onChange?: (Folder) => any,
  onDelete?: (Folder) => any,
  updateFolder: typeof api.updateFolder,
}) =>
  <EditItem
    delete={deleteFolder}
    item={folder}
    itemID={folderID}
    navigator={navigator}
    onChange={onChange}
    onDelete={onDelete}
    update={updateFolder}
  />
