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
import { shallow } from 'enzyme'

import { FilesList, mapStateToProps } from '../FilesList'

import * as template from '../../../__templates__'

const data = [
  template.folder({ type: 'folder', key: 'folder-1' }),
  template.file({ type: 'file', key: 'file-1' }),
  template.file({ type: 'file', locked: true, key: 'file-2' }),
]

jest
  .mock('../../attachments/AttachmentPicker', () => 'AttachmentPicker')
  .mock('../../../routing/Screen')
  .mock('Platform', () => ({
    OS: 'ios',
    Version: '11.2',
  }))

describe('FilesList', () => {
  it('should render', () => {
    const tree = renderer.create(
      <FilesList data={data} navigator={template.navigator()}/>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render for course files', () => {
    const tree = renderer.create(
      <FilesList data={data} navigator={template.navigator()} context={'courses'} contextID={'1'} courseColor={'red'} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render for user files', () => {
    const tree = renderer.create(
      <FilesList data={data} navigator={template.navigator()} context={'users'} contextID={'self'} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render with folders', () => {
    let tree = renderer.create(
      <FilesList data={data} folders={'course files/some_folder'} navigator={template.navigator()}/>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render with no data at all', () => {
    let tree = renderer.create(
      <FilesList data={[]} navigator={template.navigator()}/>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should call the right methods on update at the root folder', async () => {
    const courseID = '5'
    const getContextFolder = () => Promise.resolve({ data: template.folder() })
    const getFolderFolders = () => Promise.resolve({ data: [] })
    const getFolderFiles = () => Promise.resolve({ data: [] })
    const filesUpdated = jest.fn()
    const foldersUpdated = jest.fn()

    let tree = renderer.create(
      <FilesList
        contextID={courseID}
        context={'courses'}
        data={[]}
        getContextFolder={getContextFolder}
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

  it('should navigate properly to a folder', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={'courses'}/>
    ).getInstance()

    instance.onSelectRow(0)
    expect(navigator.show).toHaveBeenCalledWith('/courses/1/files/folder/some%20folder', { modal: false }, {
      canAdd: true,
      canEdit: true,
      canSelectFile: expect.any(Function),
    })
  })

  it('should navigate properly to a nested folder', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={'courses'} subFolder={'something/somewhere/over/the/rainbow'}/>
    ).getInstance()

    instance.onSelectRow(0)
    expect(navigator.show).toHaveBeenCalledWith('/courses/1/files/folder/something/somewhere/over/the/rainbow/some%20folder', { modal: false }, {
      canAdd: true,
      canEdit: true,
      canSelectFile: expect.any(Function),
    })
  })

  it('should navigate properly to a file', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={'courses'}/>
    ).getInstance()

    instance.onSelectRow(1)
    expect(navigator.show).toHaveBeenCalledWith(
      '/courses/1/files/111',
      {},
      { file: data[1], onChange: expect.any(Function) }
    )
  })

  it('calls callback on select file', () => {
    const file = template.file({
      type: 'file',
      key: 'file-1',
    })
    const onSelectFile = jest.fn()
    const view = shallow(<FilesList data={[file]} navigator={template.navigator()} onSelectFile={onSelectFile} />)
    const item = shallow(view.find('FlatList').prop('renderItem')({ item: data[0], index: 0 }))
    const row = item.find('Row')
    row.simulate('Press', 0)
    expect(onSelectFile).toHaveBeenCalledWith(file)
  })

  it('add item should open an action sheet', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={'courses'}/>
    ).getInstance()

    ActionSheetIOS.showActionSheetWithOptions = jest.fn()
    instance.addItem()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith({ 'cancelButtonIndex': 2, 'options': ['Create Folder', 'Add File', 'Cancel'] }, instance.handleAddItem)
  })

  it('adding folder should alert for text', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={'courses'}/>
    ).getInstance()

    AlertIOS.prompt = jest.fn()
    instance.handleAddItem(0)
    expect(AlertIOS.prompt).toHaveBeenCalledWith('Create Folder', null, instance.createNewFolder)
  })

  it('adding file should show the file picker stuff', () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={'courses'}/>
    ).getInstance()

    instance.attachmentPicker = {}
    instance.attachmentPicker.show = jest.fn()
    instance.handleAddItem(1)
    expect(instance.attachmentPicker.show).toHaveBeenCalled()
  })

  it('add folder to the api should work', async () => {
    const courseID = '1'
    const context = 'courses'
    const navigator = template.navigator({ show: jest.fn() })
    const createFolder = jest.fn(() => Promise.resolve())
    const folder = template.folder()
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={context} createFolder={createFolder} folder={folder} />
    ).getInstance()

    await instance.createNewFolder('folder name')
    expect(createFolder).toHaveBeenCalledWith(context, courseID, { locked: true, name: 'folder name', parent_folder_id: folder.id })
  })

  it('error thrown when adding a folder', async () => {
    const courseID = '1'
    const navigator = template.navigator({ show: jest.fn() })
    const createFolder = jest.fn(() => Promise.reject(new Error('this is messed up')))
    const folder = template.folder()
    let instance = renderer.create(
      <FilesList data={data} navigator={navigator} contextID={courseID} context={'courses'} createFolder={createFolder} folder={folder} />
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
      <FilesList data={data}
        navigator={navigator}
        contextID={courseID}
        context={'courses'}
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
      <FilesList data={data}
        navigator={navigator}
        contextID={courseID}
        context={'courses'}
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
      <FilesList data={data}
        navigator={navigator}
        contextID={courseID}
        context={'courses'}
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
      <FilesList data={data}
        navigator={navigator}
        contextID={courseID}
        context={'courses'}
        folder={folder} />
    )
    const instance = tree.getInstance()
    instance.updateUploadProgress({ loaded: 'sdfsdjkf', total: 100 })
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('shows image thumbnails', () => {
    const thumb = 'https://instructure.com/s3/thumb.jpg'
    const data = [
      template.file({
        type: 'file',
        key: 'file-1',
        thumbnail_url: thumb,
        mime_class: 'image',
      }),
    ]
    const view = shallow(<FilesList data={data} navigator={template.navigator()} />)
    const item = shallow(view.find('FlatList').prop('renderItem')({ item: data[0], index: 0 }))
    const row = item.find('Row')
    const image = shallow(row.prop('renderImage')())
    const icon = image.find('AccessIcon')
    expect(icon.prop('image').uri).toEqual(thumb)
  })

  it('uses correct icon for videos', () => {
    const data = [
      template.file({
        type: 'file',
        key: 'file-1',
        mime_class: 'video',
      }),
    ]
    const view = shallow(<FilesList data={data} navigator={template.navigator()} />)
    const item = shallow(view.find('FlatList').prop('renderItem')({ item: data[0], index: 0 }))
    const row = item.find('Row')
    const image = shallow(row.prop('renderImage')())
    const icon = image.find('AccessIcon')
    expect(icon).toMatchSnapshot()
  })

  describe('map state to props', () => {
    it('should work without folders passed in', () => {
      const contextID = '4'
      const context = 'courses'
      const folderOne = template.folder({ id: '1', name: 'files', full_name: 'files', context_type: 'course', context_id: contextID, parent_folder_id: null })
      const folderTwo = template.folder({ id: '2', name: 'zzz', full_name: 'files/zzz', context_type: 'course', context_id: contextID, parent_folder_id: folderOne.id })
      const fileOne = template.file({ id: '3', display_name: 'first', context_type: 'course', context_id: contextID, folder_id: folderOne.id })
      const fileTwo = template.file({ id: '4', display_name: 'last', context_type: 'course', context_id: contextID, folder_id: folderOne.id })

      const state = template.appState({
        folders: {
          'courses-4': {
            'root': [folderOne],
            'files': [folderTwo],
          },
        },
        files: {
          'courses-4': {
            'files': [fileOne, fileTwo],
          },
        },
      })

      const result = mapStateToProps(state, { context, contextID })
      expect(result).toMatchObject({ data: [fileOne, fileTwo, folderTwo] })
    })

    it('should work with nested folders', () => {
      const contextID = '4'
      const context = 'courses'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'course', context_id: contextID, parent_folder_id: null })
      const folderTwo = template.folder({ id: '2', full_name: 'course files/weird folder', context_type: 'course', context_id: contextID, parent_folder_id: folderOne.id })
      const folderThree = template.folder({ id: '3', name: 'zzz', full_name: 'course files/weird folder/zzz', context_type: 'course', context_id: contextID, parent_folder_id: folderTwo.id })
      const fileOne = template.file({ id: '4', display_name: 'first', context_type: 'course', context_id: contextID, folder_id: folderTwo.id })

      const state = template.appState({
        folders: {
          'courses-4': {
            'root': [folderOne],
            'course files': [folderTwo],
            'course files/weird folder': [folderThree],
          },
        },
        files: {
          'courses-4': {
            'course files/weird folder': [fileOne],
          },
        },
      })

      const result = mapStateToProps(state, { contextID, context, subFolder: 'weird folder' })
      expect(result).toMatchObject({ data: [fileOne, folderThree] })
    })

    it('should work with all missing data', () => {
      const contextID = '4'
      const context = 'courses'
      const result = mapStateToProps(template.appState(), { contextID, context })
      expect(result).toMatchObject({ data: [] })
    })

    it('root folder exists but nothing else exists', () => {
      const contextID = '4'
      const context = 'courses'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'course', context_id: contextID, parent_folder_id: null })

      const state = template.appState({
        folders: {
          'courses-4': {
            'root': [folderOne],
          },
        },
      })
      const result = mapStateToProps(state, { contextID, context })
      expect(result).toMatchObject({ data: [] })
    })

    it('root folder exists but wrong subFolder is being requested', () => {
      const contextID = '4'
      const context = 'courses'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'course', context_id: contextID, parent_folder_id: null })

      const state = template.appState({
        folders: {
          'courses-4': {
            'root': [folderOne],
          },
        },
      })
      const result = mapStateToProps(state, { contextID, context, subFolder: 'nothing here' })
      expect(result).toMatchObject({ data: [] })
    })

    it('should work with root folder but no parent folder', () => {
      const contextID = '4'
      const context = 'courses'
      const folders = 'course files/some folder'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'course', context_id: contextID, parent_folder_id: null })
      const appState = template.appState({
        folders: {
          'root': [folderOne],
        },
      })
      const result = mapStateToProps(appState, { contextID, context, folders })
      expect(result).toMatchObject({ data: [] })
    })

    it('filters out files that cant be selected', () => {
      const contextID = '4'
      const context = 'courses'
      const folderOne = template.folder({
        id: '1',
        name: 'files',
        full_name: 'files',
        context_type: 'course',
        context_id: contextID,
        parent_folder_id: null,
      })
      const folderTwo = template.folder({
        id: '2',
        name: 'zzz',
        full_name: 'files/zzz',
        context_type: 'course',
        context_id: contextID,
        parent_folder_id: folderOne.id,
      })
      const image = template.file({
        id: '3',
        display_name: 'first',
        context_type: 'course',
        context_id: contextID,
        folder_id: folderOne.id,
        mime_class: 'image',
      })
      const video = template.file({
        id: '4',
        display_name: 'last',
        context_type: 'course',
        context_id: contextID,
        folder_id: folderOne.id,
        mime_class: 'video',
      })

      const state = template.appState({
        folders: {
          'courses-4': {
            'root': [folderOne],
            'files': [folderTwo],
          },
        },
        files: {
          'courses-4': {
            'files': [image, video],
          },
        },
      })

      const canSelectFile = (file) => file.mime_class === 'image'
      const result = mapStateToProps(state, { context, contextID, canSelectFile })
      expect(result).toMatchObject({ data: [image, folderTwo] })
    })
  })
})
