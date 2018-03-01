//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */
import React from 'react'
import renderer from 'react-test-renderer'
import { ActionSheetIOS, AlertIOS, Alert } from 'react-native'

import { CourseFilesList, mapStateToProps } from '../CourseFilesList'

const template = {
  ...require('../../../__templates__/file'),
  ...require('../../../__templates__/folder'),
  ...require('../../../__templates__/attachment'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

const data = [
  template.folder({ type: 'folder', key: 'folder-1' }),
  template.file({ type: 'file', key: 'file-1' }),
  template.file({ type: 'file', locked: true, key: 'file-2' }),
]

jest
  .mock('../../attachments/AttachmentPicker', () => 'AttachmentPicker')
  .mock('../../../routing/Screen')

describe('CourseFileList', () => {
  it('should render', () => {
    const tree = renderer.create(
      <CourseFilesList data={data} navigator={template.navigator()}/>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render with folders', () => {
    let tree = renderer.create(
      <CourseFilesList data={data} folders={'course files/some_folder'} navigator={template.navigator()}/>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render with no data at all', () => {
    let tree = renderer.create(
      <CourseFilesList data={[]} navigator={template.navigator()}/>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should call the right methods on update at the root folder', async () => {
    const courseID = '5'
    const getCourseFolder = () => Promise.resolve({ data: template.folder() })
    const getFolderFolders = () => Promise.resolve({ data: [] })
    const getFolderFiles = () => Promise.resolve({ data: [] })
    const filesUpdated = jest.fn()
    const foldersUpdated = jest.fn()

    let tree = renderer.create(
      <CourseFilesList
        courseID={courseID}
        data={[]}
        getCourseFolder={getCourseFolder}
        getFolderFolders={getFolderFolders}
        getFolderFiles={getFolderFiles}
        filesUpdated={filesUpdated}
        foldersUpdated={foldersUpdated}
        navigator={template.navigator()} />
    )

    await tree.getInstance().update()
    expect(filesUpdated).toHaveBeenCalled()
    expect(foldersUpdated).toHaveBeenCalled()
  })

  it('should navigator properly to a folder', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID}/>
    ).getInstance()

    instance.onSelectRow(0)
    expect(navigator.show).toHaveBeenCalledWith('/courses/1/files/folder/some folder')
  })

  it('should navigator properly to a nested folder', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID} subFolder={'something/somewhere/over/the/rainbow'}/>
    ).getInstance()

    instance.onSelectRow(0)
    expect(navigator.show).toHaveBeenCalledWith('/courses/1/files/folder/something/somewhere/over/the/rainbow/some folder')
  })

  it('should navigator properly to a file', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID}/>
    ).getInstance()

    instance.onSelectRow(1)
    expect(navigator.show).toHaveBeenCalledWith(
      '/courses/1/file/111',
      { modal: true },
      { file: data[1], onChange: expect.any(Function) }
    )
  })

  it('add item should open an action sheet', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID}/>
    ).getInstance()

    ActionSheetIOS.showActionSheetWithOptions = jest.fn()
    instance.addItem()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith({ 'cancelButtonIndex': 2, 'options': ['Create Folder', 'Add File', 'Cancel'] }, instance.handleAddItem)
  })

  it('adding folder should alert for text', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID}/>
    ).getInstance()

    AlertIOS.prompt = jest.fn()
    instance.handleAddItem(0)
    expect(AlertIOS.prompt).toHaveBeenCalledWith('Create Folder', null, instance.createNewFolder)
  })

  it('adding file should show the file picker stuff', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID}/>
    ).getInstance()

    instance.attachmentPicker = {}
    instance.attachmentPicker.show = jest.fn()
    instance.handleAddItem(1)
    expect(instance.attachmentPicker.show).toHaveBeenCalled()
  })

  it('add folder to the api should work', async () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    const createFolder = jest.fn(() => Promise.resolve())
    const folder = template.folder()
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID} createFolder={createFolder} folder={folder} />
    ).getInstance()

    await instance.createNewFolder('folder name')
    expect(createFolder).toHaveBeenCalledWith(courseID, { locked: true, name: 'folder name', parent_folder_id: folder.id })
  })

  it('error thrown when adding a folder', async () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    const createFolder = jest.fn(() => Promise.reject(new Error('this is messed up')))
    const folder = template.folder()
    let instance = renderer.create(
      <CourseFilesList data={data} navigator={navigator} courseID={courseID} createFolder={createFolder} folder={folder} />
    ).getInstance()

    Alert.alert = jest.fn()
    await instance.createNewFolder('folder name')
    expect(Alert.alert).toHaveBeenCalled()
  })

  it('upload a file please', async () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    const uploadFile = jest.fn(() => Promise.resolve([]))
    const getFolderFolders = () => Promise.resolve({ data: [] })
    const getFolderFiles = () => Promise.resolve({ data: [] })
    const filesUpdated = jest.fn()
    const folder = template.folder()
    let instance = renderer.create(
      <CourseFilesList data={data}
                       navigator={navigator}
                       courseID={courseID}
                       uploadFile={uploadFile}
                       folder={folder}
                       getFolderFiles={getFolderFiles}
                       getFolderFolders={getFolderFolders}
                       filesUpdated={filesUpdated}
                       foldersUpdated={jest.fn()} />
    ).getInstance()

    await instance.finishAddFile(template.attachment())
    expect(uploadFile).toHaveBeenCalled()
    expect(filesUpdated).toHaveBeenCalled()
  })

  it('upload a file has an error', async () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    const uploadFile = jest.fn(() => Promise.reject(new Error('this is messed up')))
    const folder = template.folder()
    let instance = renderer.create(
      <CourseFilesList data={data}
                       navigator={navigator}
                       courseID={courseID}
                       uploadFile={uploadFile}
                       folder={folder} />
    ).getInstance()

    Alert.alert = jest.fn()
    await instance.finishAddFile(template.attachment())
    expect(uploadFile).toHaveBeenCalled()
    expect(Alert.alert).toHaveBeenCalled()
  })

  it('progress function should update the UI correctly', async () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    const folder = template.folder()
    let tree = renderer.create(
      <CourseFilesList data={data}
                       navigator={navigator}
                       courseID={courseID}
                       folder={folder} />
    )
    const instance = tree.getInstance()
    instance.updateUploadProgress({ loaded: 0, total: 100 })
    expect(tree.toJSON()).toMatchSnapshot()
    instance.updateUploadProgress({ loaded: 50, total: 100 })
    expect(tree.toJSON()).toMatchSnapshot()
    instance.updateUploadProgress({ loaded: 100, total: 100 })
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('sending weird data into the progress update function should not break all the things', async () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    const folder = template.folder()
    let tree = renderer.create(
      <CourseFilesList data={data}
                       navigator={navigator}
                       courseID={courseID}
                       folder={folder} />
    )
    const instance = tree.getInstance()
    instance.updateUploadProgress({ loaded: 'sdfsdjkf', total: 100 })
    expect(tree.toJSON()).toMatchSnapshot()
  })

  describe('map state to props', () => {
    it('should work without folders passed in', () => {
      const courseID = '4'
      const folderOne = template.folder({ id: '1', name: 'files', full_name: 'files', context_type: 'Course', context_id: courseID, parent_folder_id: null })
      const folderTwo = template.folder({ id: '2', name: 'zzz', full_name: 'files/zzz', context_type: 'Course', context_id: courseID, parent_folder_id: folderOne.id })
      const fileOne = template.file({ id: '3', display_name: 'first', context_type: 'Course', context_id: courseID, folder_id: folderOne.id })
      const fileTwo = template.file({ id: '4', display_name: 'last', context_type: 'Course', context_id: courseID, folder_id: folderOne.id })

      const state = template.appState({
        folders: {
          'Course-4': {
            'root': [folderOne],
            'files': [folderTwo],
          },
        },
        files: {
          'Course-4': {
            'files': [fileOne, fileTwo],
          },
        },
      })

      const result = mapStateToProps(state, { courseID })
      expect(result).toMatchObject({ data: [fileOne, fileTwo, folderTwo] })
    })

    it('should work with nested folders', () => {
      const courseID = '4'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'Course', context_id: courseID, parent_folder_id: null })
      const folderTwo = template.folder({ id: '2', full_name: 'course files/weird folder', context_type: 'Course', context_id: courseID, parent_folder_id: folderOne.id })
      const folderThree = template.folder({ id: '3', name: 'zzz', full_name: 'course files/weird folder/zzz', context_type: 'Course', context_id: courseID, parent_folder_id: folderTwo.id })
      const fileOne = template.file({ id: '4', display_name: 'first', context_type: 'Course', context_id: courseID, folder_id: folderTwo.id })

      const state = template.appState({
        folders: {
          'Course-4': {
            'root': [folderOne],
            'course files': [folderTwo],
            'course files/weird folder': [folderThree],
          },
        },
        files: {
          'Course-4': {
            'course files/weird folder': [fileOne],
          },
        },
      })

      const result = mapStateToProps(state, { courseID, subFolder: 'weird folder' })
      expect(result).toMatchObject({ data: [fileOne, folderThree] })
    })

    it('should work with all missing data', () => {
      const courseID = '4'
      const result = mapStateToProps(template.appState(), { courseID })
      expect(result).toMatchObject({ data: [] })
    })

    it('root folder exists but nothing else exists', () => {
      const courseID = '4'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'Course', context_id: courseID, parent_folder_id: null })

      const state = template.appState({
        folders: {
          'Course-4': {
            'root': [folderOne],
          },
        },
      })
      const result = mapStateToProps(state, { courseID })
      expect(result).toMatchObject({ data: [] })
    })

    it('root folder exists but wrong subFolder is being requested', () => {
      const courseID = '4'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'Course', context_id: courseID, parent_folder_id: null })

      const state = template.appState({
        folders: {
          'Course-4': {
            'root': [folderOne],
          },
        },
      })
      const result = mapStateToProps(state, { courseID, subFolder: 'nothing here' })
      expect(result).toMatchObject({ data: [] })
    })

    it('should work with root folder but no parent folder', () => {
      const courseID = '4'
      const folders = 'course files/some folder'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'Course', context_id: courseID, parent_folder_id: null })
      const appState = template.appState({
        folders: {
          'root': [folderOne],
        },
      })
      const result = mapStateToProps(appState, { courseID, folders })
      expect(result).toMatchObject({ data: [] })
    })
  })
})
