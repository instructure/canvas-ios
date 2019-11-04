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

import i18n from 'format-message'
import React, { Component } from 'react'
import ReactNative, {
  View,
  LayoutAnimation,
  PickerIOS,
  findNodeHandle,
  NativeModules,
} from 'react-native'
import Screen from '../../../routing/Screen'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { Heading1, FormLabel } from '../../../common/text'
import RowWithTextInput from '../../../common/components/rows/RowWithTextInput'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowWithDetail from '../../../common/components/rows/RowWithDetail'
import SavingBanner from '../../../common/components/SavingBanner'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import { createStyleSheet } from '../../../common/stylesheet'
import {
  fetchPropsFor,
  type FetchProps,
  PageModel,
} from '../../../canvas-api/model-api'
import { alertError } from '../../../redux/middleware/error-handler'
import { isTeacher } from '../../app'

const PickerItem = PickerIOS.Item
const { NativeNotificationCenter } = NativeModules

type HocProps = {
  courseID: string,
  url?: ?string,
  navigator: Navigator,
  onChange?: PageModel => void,
}
type Props = HocProps & {
  page: ?PageModel,
} & FetchProps

type State = {
  title: ?string,
  body: ?string,
  editingRoles: string[],
  published: boolean,
  isFrontPage: boolean,
  editingRolesPickerShown: boolean,
}

function editingRoles () {
  return {
    'teachers': i18n('Only teachers'),
    'students,teachers': i18n('Teachers and students'),
    'public': i18n('Anyone'),
  }
}

export class PageEdit extends Component<Props, State> {
  scrollView: ?KeyboardAwareScrollView
  editor: ?RichTextEditor

  state: State = {
    ...(this.props.page || PageModel.newPage),
    editingRolesPickerShown: false,
  }

  componentWillReceiveProps ({ page, loadError }: Props) {
    if (loadError && loadError !== this.props.loadError) alertError(loadError)
    if (this.props.page == null && page != null) {
      this.setState(page) // page finally loaded, reset form
    }
  }

  render () {
    const { page } = this.props
    const title = this.isEdit() ? i18n('Edit Page') : i18n('New Page')
    let editingRole = 'public'
    if (this.state.editingRoles.includes('teachers')) editingRole = 'teachers'
    if (this.state.editingRoles.includes('students')) editingRole = 'students,teachers'

    return (
      <Screen
        title={title}
        rightBarButtons={[
          {
            title: i18n('Done'),
            testID: 'pages.edit.doneButton',
            style: 'done',
            action: this.done,
          },
        ]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <View style={{ flex: 1 }}>
          { this.props.isSaving && <SavingBanner /> }
          <KeyboardAwareScrollView
            style={style.container}
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
            ref={(r) => { this.scrollView = r }}
            keyboardDismissMode='on-drag'
          >
            {isTeacher()
              ? <View>
                <FormLabel>{i18n('Title')}</FormLabel>
                <RowWithTextInput
                  defaultValue={this.state.title}
                  border='both'
                  onChangeText={this.handleTitleChange}
                  identifier='pages.edit.titleInput'
                  placeholder={i18n('Add title')}
                  onFocus={this._scrollToInput}
                />
              </View>
              : <Heading1 style={style.studentTitle}>{this.state.title}</Heading1>
            }
            <FormLabel>{i18n('Description')}</FormLabel>
            <View
              style={style.description}
            >
              <RichTextEditor
                ref={(r) => { this.editor = r }}
                defaultValue={this.props.page ? this.props.page.body : null}
                showToolbar='always'
                keyboardAware={false}
                scrollEnabled
                contentHeight={150}
                placeholder={i18n('Add description')}
                navigator={this.props.navigator}
                attachmentUploadPath={`/courses/${this.props.courseID}/files`}
                onFocus={this._scrollToRCE}
                context='courses'
                contextID={this.props.courseID}
              />
            </View>
            {isTeacher() &&
              <View>
                <FormLabel>{i18n('Details')}</FormLabel>
                { !this.state.isFrontPage &&
                  <RowWithSwitch
                    title={i18n('Publish')}
                    border='bottom'
                    value={this.state.published}
                    onValueChange={this.handlePublishedChange}
                    testID='pages.edit.published.row'
                    identifier='pages.edit.published.switch'
                  />
                }
                { !(page && page.isFrontPage) && this.state.published &&
                  <RowWithSwitch
                    title={i18n('Set as Front Page')}
                    border='both'
                    value={this.state.isFrontPage}
                    onValueChange={this.handleIsFrontPageChange}
                    testID='pages.edit.front_page.row'
                    identifier='pages.edit.front_page.switch'
                  />
                }
                <RowWithDetail
                  title={i18n('Can Edit')}
                  detailSelected={this.state.editingRolesPickerShown}
                  detail={editingRoles()[editingRole]}
                  disclosureIndicator
                  border='bottom'
                  onPress={this.toggleEditingRoles}
                  testID='pages.edit.editing_roles.row'
                />
                {this.state.editingRolesPickerShown &&
                  <PickerIOS
                    selectedValue={editingRole}
                    onValueChange={this.handleEditingRolesChange}
                    testID='pages.edit.editing_roles.picker'
                  >
                    {Object.keys(editingRoles()).map(key => (
                      <PickerItem
                        key={key}
                        value={key}
                        label={editingRoles()[key]}
                      />
                    ))}
                  </PickerIOS>
                }
              </View>
            }
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }

  done = async () => {
    const body = this.editor && await this.editor.getHTML()
    const parameters = {
      title: this.state.title,
      body,
      editing_roles: this.state.editingRoles.join(','),
      published: this.state.isFrontPage || this.state.published,
      front_page: this.state.isFrontPage,
    }
    try {
      const { api, courseID, url } = this.props
      const request = url
        ? api.updatePage('courses', courseID, url, parameters)
        : api.createPage('courses', courseID, parameters)
      const response = await request
      if (url) {
        NativeNotificationCenter.postNotification('page-edit', response.data.raw)
      } else {
        NativeNotificationCenter.postNotification('page-created', response.data.raw)
      }
      await this.props.navigator.dismiss()
      this.props.onChange && this.props.onChange(response.data)
    } catch (error) {
      alertError(error)
    }
  }

  handleTitleChange = (title: string) => {
    LayoutAnimation.easeInEaseOut()
    this.setState({ title })
  }

  handlePublishedChange = (published: boolean) => {
    LayoutAnimation.easeInEaseOut()
    this.setState({ published })
  }

  handleIsFrontPageChange = (isFrontPage: boolean) => {
    LayoutAnimation.easeInEaseOut()
    this.setState({ isFrontPage })
  }

  handleEditingRolesChange = (roles: string) => {
    LayoutAnimation.easeInEaseOut()
    this.setState({ editingRoles: roles.split(',') })
  }

  isEdit = () => this.props.url != null

  toggleEditingRoles = () => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut, () => {
      this.scrollView && this.scrollView.scrollToEnd()
    })
    this.setState({
      editingRolesPickerShown: !this.state.editingRolesPickerShown,
    })
  }

  _scrollToInput = (event: any) => {
    const input = findNodeHandle(event.target)
    this.scrollView &&
    input &&
    // the types on keyboard-aware-scroll-view were incorrect
    // https://github.com/APSL/react-native-keyboard-aware-scroll-view/pull/207
    // $FlowFixMe
    this.scrollView.scrollToFocusedInput(input)
  }

  _scrollToRCE = () => {
    const input = ReactNative.findNodeHandle(this.editor)
    // $FlowFixMe
    this.scrollView.scrollToFocusedInput(input)
  }
}

const style = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    backgroundColor: colors.backgroundGrouped,
  },
  description: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    backgroundColor: colors.backgroundLightest,
    height: 200,
  },
  studentTitle: {
    padding: 12,
  },
}))

export default fetchPropsFor(PageEdit, ({ courseID, url }: HocProps, api) => ({
  page: !url ? PageModel.newPage : api.getPage('courses', courseID, url),
}))
