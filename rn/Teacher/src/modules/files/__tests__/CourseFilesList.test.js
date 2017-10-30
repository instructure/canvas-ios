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

/**
 * @flow
 */
import React from 'react'
import renderer from 'react-test-renderer'

import { CourseFilesList, mapStateToProps } from '../CourseFilesList'

const template = {
  ...require('../../../__templates__/file'),
  ...require('../../../__templates__/folder'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

const data = [
  template.folder({ type: 'folder', key: 'folder-1' }),
  template.file({ type: 'file', key: 'file-1' }),
  template.file({ type: 'file', locked: true, key: 'file-2' }),
]

describe('CourseFileList', () => {
  it('should render', () => {
    const tree = renderer.create(
      <CourseFilesList data={data} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render with folders', () => {
    let tree = renderer.create(
      <CourseFilesList data={data} folders={'course files/some_folder'} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should render with no data at all', () => {
    let tree = renderer.create(
      <CourseFilesList data={[]} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('should call the right methods on update at the root folder', async () => {
    const courseID = '5'
    const getCourseFolder = jest.fn(() => Promise.resolve({ data: template.folder() }))
    const getFolderFolders = jest.fn(() => Promise.resolve([]))
    const getFolderFiles = jest.fn(() => Promise.resolve([]))
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
        foldersUpdated={foldersUpdated} />
    )

    await tree.getInstance().update()
    expect(getCourseFolder).toHaveBeenCalled()
    expect(getFolderFolders).toHaveBeenCalled()
    expect(getFolderFiles).toHaveBeenCalled()
    expect(filesUpdated).toHaveBeenCalled()
    expect(foldersUpdated).toHaveBeenCalled()
  })

  it('should call the right methods on update at the root folder', async () => {
    const courseID = '5'
    const getFolderFolders = jest.fn(() => Promise.resolve([]))
    const getFolderFiles = jest.fn(() => Promise.resolve([]))
    const filesUpdated = jest.fn()
    const foldersUpdated = jest.fn()

    let tree = renderer.create(
      <CourseFilesList
        courseID={courseID}
        data={[]}
        folder={ template.folder() }
        getFolderFolders={getFolderFolders}
        getFolderFiles={getFolderFiles}
        filesUpdated={filesUpdated}
        foldersUpdated={foldersUpdated} />
    )

    await tree.getInstance().update()
    expect(getFolderFolders).toHaveBeenCalled()
    expect(getFolderFiles).toHaveBeenCalled()
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
      '/attachment',
      { modal: true },
      { attachment: data[1] })
  })

  describe('map state to props', () => {
    it('should work without folders passed in', () => {
      const courseID = '4'
      const folderOne = template.folder({ id: '1', context_type: 'Course', context_id: courseID, parent_folder_id: null })
      const folderTwo = template.folder({ id: '2', name: 'zzz', context_type: 'Course', context_id: courseID, parent_folder_id: folderOne.id })
      const fileOne = template.file({ id: '3', display_name: 'first', context_type: 'Course', context_id: courseID, folder_id: folderOne.id })
      const fileTwo = template.file({ id: '4', display_name: 'last', context_type: 'Course', context_id: courseID, folder_id: folderOne.id })
      const state = template.appState({
        entities: {
          folders: {
            [folderOne.id]: folderOne,
            [folderTwo.id]: folderTwo,
          },
          files: {
            [fileOne.id]: fileOne,
            [fileTwo.id]: fileTwo,
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
      const folderThree = template.folder({ id: '3', name: 'zzz', context_type: 'Course', context_id: courseID, parent_folder_id: folderTwo.id })
      const fileOne = template.file({ id: '4', display_name: 'first', context_type: 'Course', context_id: courseID, folder_id: folderTwo.id })
      const state = template.appState({
        entities: {
          folders: {
            [folderOne.id]: folderOne,
            [folderTwo.id]: folderTwo,
            [folderThree.id]: folderThree,
          },
          files: {
            [fileOne.id]: fileOne,
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

    it('should work with root folder but no parent folder', () => {
      const courseID = '4'
      const folders = 'course files/some folder'
      const folderOne = template.folder({ id: '1', name: 'course files', context_type: 'Course', context_id: courseID, parent_folder_id: null })
      const appState = template.appState({
        entities: {
          folders: {
            [folderOne.id]: folderOne,
          },
          files: {},
        },
      })
      const result = mapStateToProps(appState, { courseID, folders })
      expect(result).toMatchObject({ data: [] })
    })
  })
})
