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

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  ActionSheetIOS,
  Alert,
} from 'react-native'
import Actions from './actions'
import { alertError } from '../../../redux/middleware/error-handler'
import { getPage, deletePage } from '../../../canvas-api'
import WebContainer from '../../../common/components/WebContainer'
import Screen from '../../../routing/Screen'
import i18n from 'format-message'
import Images from '../../../images'
import { Heading1 } from '../../../common/text'
import { isTeacher } from '../../app'

type StateProps = {
  pages: { [string]: Page },
  courseName: string,
  courseColor: ?string,
}

type OwnProps = {
  courseID: string,
  url: string,
}

type State = {
  page: ?Page,
  page_id: ?string,
}

export type Props = OwnProps & StateProps & NavigationProps & typeof Actions & {
  getPage: typeof getPage,
  deletePage: typeof deletePage,
}

export class PageDetails extends Component<Props, any> {
  state: State

  static defaultProps = {
    getPage,
    deletePage,
  }

  constructor (props: Props) {
    super(props)

    this.state = {
      page: null,
      page_id: null,
    }
  }

  // $FlowFixMe
  async componentWillMount () {
    await this.refresh()
  }

  componentWillReceiveProps (nextProps: Props) {
    if (this.state.page_id) {
      this.setState({ page: nextProps.pages[this.state.page_id] })
    }
  }

  render () {
    const { page } = this.state
    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        title={i18n('Page Details')}
        subtitle={this.props.courseName}
        rightBarButtons={isTeacher() && [
          {
            image: Images.kabob,
            testID: 'pages.details.editButton',
            accessibilityLabel: i18n('Options'),
            action: this.showEditActionSheet,
          },
        ]}
      >
        <View style={styles.container}>
          <Heading1 style={styles.header}>{page ? page.title : ''}</Heading1>
          <WebContainer
            style={{ flex: 1 }}
            html={page ? page.body : ''}
            navigator={this.props.navigator}
          />
        </View>
      </Screen>
    )
  }

  refresh = async () => {
    // We can only refresh once (on mount)
    // because the url may have changed from Edit.
    if (this.state.page_id) return

    try {
      const { data } = await this.props.getPage(this.props.courseID, this.props.url)
      this.setState({ page_id: data.page_id })
      this.props.refreshedPage(data, this.props.courseID)
    } catch (error) {
      alertError(error)
    }
  }

  edit = () => {
    if (!this.state.page) return
    const route = `/courses/${this.props.courseID}/pages/${this.state.page.url}/edit`
    this.props.navigator.show(route, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  showEditActionSheet = () => {
    if (!this.state.page) return
    const canDelete = !this.state.page.front_page
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
    if (!this.state.page) return
    const canDelete = !this.state.page.front_page
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
    if (!this.state.page) return
    try {
      await this.props.deletePage(this.props.courseID, this.state.page.url)
      this.props.deletedPage(this.state.page, this.props.courseID)
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

export function mapStateToProps ({ entities }: AppState, { courseID, url }: OwnProps): StateProps {
  let pages = {}
  let courseName = ''
  let courseColor = null
  if (entities &&
    entities.courses &&
    entities.courses[courseID]) {
    const course = entities.courses[courseID]
    courseName = course.course && course.course.name
    courseColor = course.color
    if (course.pages && course.pages.refs) {
      pages = course.pages.refs
        .reduce((memo, ref) => ({
          ...memo,
          [ref]: entities.pages[ref].data,
        }), {})
    }
  }

  return {
    pages,
    courseName,
    courseColor,
  }
}

const Connected = connect(mapStateToProps, Actions)(PageDetails)
export default (Connected: Component<Props, any>)
