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

import i18n from 'format-message'
import React, { Component } from 'react'
import {
  StyleSheet,
  ActionSheetIOS,
  Alert,
} from 'react-native'
import { alertError } from '../../../redux/middleware/error-handler'
import {
  API,
  fetchPropsFor,
  PageModel,
  CourseModel,
} from '../../../canvas-api/model-api'
import CanvasWebView from '../../../common/components/CanvasWebView'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import Screen from '../../../routing/Screen'
import Images from '../../../images'
import { Heading1 } from '../../../common/text'
import { isTeacher } from '../../app'

type Props = {
  location: URL,
  courseID: string,
  url: string,
  navigator: Navigator,
  page: ?PageModel,
  course: ?CourseModel,
  courseColor: string,
  api: API,
  isLoading: boolean,
  loadError: ?Error,
  refresh: () => void,
}

export class PageDetails extends Component<Props> {
  componentWillReceiveProps ({ loadError }: Props) {
    if (loadError && loadError !== this.props.loadError) alertError(loadError)
  }

  render () {
    const { course, courseColor, page, location } = this.props
    const customPageViewPath = page && page.isFrontPage && course ? { customPageViewPath: `/courses/${course.id}/wiki` } : {}
    return (
      <Screen
        {...customPageViewPath}
        navBarColor={courseColor}
        navBarStyle='dark'
        title={i18n('Page Details')}
        subtitle={course && course.name || undefined}
        rightBarButtons={isTeacher() && [
          {
            image: Images.kabob,
            testID: 'pages.details.editButton',
            accessibilityLabel: i18n('Options'),
            action: this.showEditActionSheet,
          },
        ]}
      >
        <RefreshableScrollView
          style={styles.container}
          onRefresh={this.props.refresh}
          refreshing={this.props.isLoading}
        >
          <Heading1 style={styles.header}>{page ? page.title : ''}</Heading1>
          <CanvasWebView
            automaticallySetHeight
            style={{ flex: 1 }}
            source={{
              html: page ? page.body : '',
              baseURL: page ? page.htmlUrl + location.hash : '',
            }}
            navigator={this.props.navigator}
          />
        </RefreshableScrollView>
      </Screen>
    )
  }

  edit = () => {
    const { courseID, page } = this.props
    if (!page) return
    const route = `/courses/${courseID}/pages/${page.url}/edit`
    this.props.navigator.show(route, {
      modal: true,
      modalPresentationStyle: 'formsheet',
    }, {
      onChange: this.handleChanged,
    })
  }

  handleChanged = (changed: PageModel) => {
    const { courseID, navigator, page } = this.props
    if (!page || (page.url !== changed.url)) {
      navigator.replace(`/courses/${courseID}/pages/${changed.url}`)
    }
  }

  showEditActionSheet = () => {
    if (!this.props.page) return
    const canDelete = !this.props.page.isFrontPage
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options: [i18n('Edit'), canDelete ? i18n('Delete') : null, i18n('Cancel')].filter(o => o),
        destructiveButtonIndex: canDelete ? 1 : -1,
        cancelButtonIndex: canDelete ? 2 : 1,
      },
      this._editActionSheetSelected,
    )
  }

  _editActionSheetSelected = (index: number) => {
    if (!this.props.page) return
    const canDelete = !this.props.page.isFrontPage
    switch (index) {
      case 0:
        this.edit()
        break
      case 1:
        canDelete && this._confirmDelete()
        break
    }
  }

  _confirmDelete = () => {
    const alertTitle = i18n('Are you sure you want to delete this page?')
    Alert.alert(
      alertTitle,
      null,
      [
        { text: i18n('Cancel'), style: 'cancel' },
        { text: i18n('OK'), onPress: this.delete },
      ],
    )
  }

  delete = async () => {
    const { api, courseID, page } = this.props
    if (!page) return
    try {
      await api.deletePage('courses', courseID, page.url)
      this.props.navigator.pop()
    } catch (error) {
      alertError(error)
    }
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: global.style.defaultPadding,
  },
  header: {
    paddingBottom: 17,
  },
})

export default fetchPropsFor(PageDetails, ({ courseID, url }, api) => {
  let pageApi
  if (url === 'front_page') {
    pageApi = api.getFrontPage(courseID)
  } else {
    pageApi = api.getPage('courses', courseID, url)
  }
  return {
    courseColor: api.getCourseColor(courseID),
    course: api.getCourse(courseID),
    page: pageApi,
  }
})
