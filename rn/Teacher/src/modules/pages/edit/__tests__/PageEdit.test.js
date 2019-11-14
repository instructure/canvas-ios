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

// @flow

import { shallow } from 'enzyme'
import React from 'react'
import { alertError } from '../../../../redux/middleware/error-handler'
import { API, httpCache, PageModel } from '../../../../canvas-api/model-api'
import * as template from '../../../../__templates__'
import ConnectedPageEdit, { PageEdit } from '../PageEdit'
import app from '../../../app'

jest.mock('../../../../redux/middleware/error-handler', () => {
  return { alertError: jest.fn() }
})
jest.useFakeTimers()

describe('PageEdit', () => {
  let props: Object
  beforeEach(() => {
    httpCache.clear()
    props = {
      courseID: '1',
      url: null,
      navigator: template.navigator(),
      page: PageModel.newPage,
      api: new API({ policy: 'cache-only' }),
      isLoading: false,
      isSaving: false,
      loadError: null,
      saveError: null,
      refresh: jest.fn(),
    }
  })

  it('gets page from the model api', () => {
    const page = template.pageModel({ url: 'test' })
    httpCache.handle('GET', 'courses/1/pages/test', page)
    const tree = shallow(<ConnectedPageEdit courseID='1' url='test' navigator={template.navigator()} />)
    expect(tree.find(PageEdit).props()).toMatchObject({
      page,
    })
  })

  it('gets newPage when url is null', () => {
    const tree = shallow(<ConnectedPageEdit courseID='1' navigator={template.navigator()} />)
    expect(tree.find(PageEdit).props()).toMatchObject({
      page: PageModel.newPage,
    })
  })

  it('renders', () => {
    app.setCurrentApp('teacher')
    expect(shallow(<PageEdit {...props} />)).toMatchSnapshot()
  })

  it('renders when the student app', () => {
    app.setCurrentApp('student')
    props.page.editingRoles = ['students', 'teacher']
    expect(shallow(<PageEdit {...props} />)).toMatchSnapshot()
    app.setCurrentApp('teacher')
  })

  it('alerts on new loadError', () => {
    const tree = shallow(<PageEdit {...props} />)
    tree.setProps({ loadError: null })
    expect(alertError).not.toHaveBeenCalled()
    const loadError = new Error()
    tree.setProps({ loadError })
    expect(alertError).toHaveBeenCalledWith(loadError)
  })

  it('sets the form state when the page finally loads', () => {
    props.page = null
    const tree = shallow(<PageEdit {...props} />)
    const page = template.pageModel()
    tree.setProps({ page })
    expect(tree.state('title')).toBe(page.title)
  })

  describe('front page edit', () => {
    beforeEach(() => {
      props.url = 'page-1'
      props.page = template.pageModel({ url: 'page-1', isFrontPage: true })
    })

    it('hides front page switch', () => {
      const tree = shallow(<PageEdit {...props} />)
      const row = tree.find('[testID="pages.edit.front_page.row"]')
      expect(row.exists()).toBe(false)
    })

    it('hides published switch', () => {
      const tree = shallow(<PageEdit {...props} />)
      const row = tree.find('[testID="pages.edit.published.row"]')
      expect(row.exists()).toBe(false)
    })
  })

  it('can edit front page if published', () => {
    const tree = shallow(<PageEdit {...props} />)
    tree.find('[identifier="pages.edit.published.switch"]')
      .simulate('ValueChange', true)
    const row = tree.find('[testID="pages.edit.front_page.row"]')
    expect(row.exists()).toBe(true)
  })

  it('can edit published', () => {
    const tree = shallow(<PageEdit {...props} />)
    const row = tree.find('[testID="pages.edit.published.row"]')
    expect(row.exists()).toBe(true)
  })

  it('creates new page with values', async () => {
    props.api.createPage = jest.fn()
    const tree = shallow(<PageEdit {...props} />)
    tree.find('[identifier="pages.edit.titleInput"]')
      .simulate('ChangeText', 'Page 1')
    tree.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve('This is the body')),
    })
    tree.find('[testID="pages.edit.editing_roles.row"]')
      .simulate('Press')
    tree.find('[testID="pages.edit.editing_roles.picker"]')
      .simulate('ValueChange', 'students,teachers')
    tree.find('[identifier="pages.edit.published.switch"]')
      .simulate('ValueChange', true)
    tree.find('[identifier="pages.edit.front_page.switch"]')
      .simulate('ValueChange', true)
    await tapDone(tree)

    expect(props.api.createPage).toHaveBeenCalledWith('courses', '1', {
      title: 'Page 1',
      body: 'This is the body',
      editing_roles: 'students,teachers',
      published: true,
      front_page: true,
    })
  })

  it('updates page with values', async () => {
    props.api.updatePage = jest.fn()
    props.url = 'page-1'
    props.page = template.pageModel({ url: 'page-1', title: 'Page 1', editingRoles: [ 'public' ] })
    const tree = shallow(<PageEdit {...props} />)
    tree.find('[identifier="pages.edit.titleInput"]')
      .simulate('ChangeText', 'Page 1 (Edited)')
    tree.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve(props.page.body)),
    })
    await tapDone(tree)

    expect(props.api.updatePage).toHaveBeenCalledWith('courses', '1', 'page-1', {
      title: 'Page 1 (Edited)',
      body: '<p>Hello, World!</p>',
      editing_roles: 'public',
      published: true,
      front_page: false,
    })
  })

  it('publishes page if front page', async () => {
    props.api.updatePage = jest.fn()
    props.url = 'page-1'
    props.page = template.pageModel({
      isFrontPage: true,
      published: false,
      url: 'page-1',
    })
    const tree = shallow(<PageEdit {...props} />)
    tree.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve(props.page.body)),
    })
    await tapDone(tree)

    expect(props.api.updatePage).toHaveBeenCalledWith('courses', '1', 'page-1', {
      title: 'Page 1',
      body: '<p>Hello, World!</p>',
      editing_roles: 'teachers',
      published: true,
      front_page: true,
    })
  })

  it('alerts save errors', async () => {
    const error = new Error('title cant be blank')
    props.api.createPage = jest.fn(() => Promise.reject(error))
    const tree = shallow(<PageEdit {...props} />)
    await tapDone(tree)
    expect(alertError).toHaveBeenCalledWith(error)
  })

  it('shows SavingBanner while saving', async () => {
    const tree = shallow(<PageEdit {...props} />)
    expect(tree.find('SavingBanner').exists()).toBe(false)
    tree.setProps({ isSaving: true })
    expect(tree.find('SavingBanner').exists()).toBe(true)
  })

  it('dismisses on Done', async () => {
    props.navigator = template.navigator({ dismiss: jest.fn() })
    props.api.createPage = () => Promise.resolve({ data: { raw: {} } })
    props.onChange = jest.fn()
    const tree = shallow(<PageEdit {...props} />)
    await tapDone(tree)
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('scrolls view when RichTextEditor receives focus', () => {
    const spy = jest.fn()
    const tree = shallow(<PageEdit {...props} />)
    tree.find('KeyboardAwareScrollView').getElement().ref({ scrollToFocusedInput: spy })
    tree.find('RichTextEditor').simulate('Focus')
    expect(spy).toHaveBeenCalled()
  })

  function tapDone (tree: any) {
    return tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.edit.doneButton')
      .action()
  }
})
