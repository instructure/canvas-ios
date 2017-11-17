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
} from 'react-native'
import Actions from './actions'
import { alertError } from '../../../redux/middleware/error-handler'
import { getPage } from '../../../canvas-api'
import WebContainer from '../../../common/components/WebContainer'
import Screen from '../../../routing/Screen'

type StateProps = {
  page: ?Page,
  courseName: string,
}

type OwnProps = {
  courseID: string,
  url: string,
}

export type Props = OwnProps & StateProps & NavigationProps & typeof Actions & {
  getPage: typeof getPage,
}

export class PageDetails extends Component<Props, any> {
  static defaultProps = {
    getPage,
  }

  // $FlowFixMe
  async componentWillMount () {
    await this.refresh()
  }

  render () {
    const { page } = this.props
    return (
      <Screen
        navBarStyle='dark'
        title={this.props.page ? this.props.page.title : ''}
        subtitle={this.props.courseName}
      >
        <View style={styles.container}>
          <WebContainer
            style={{ flex: 1 }}
            html={page && page.body || ''}
          />
        </View>
      </Screen>
    )
  }

  refresh = async () => {
    try {
      const { data } = await this.props.getPage(this.props.courseID, this.props.url)
      this.props.refreshedPage(data, this.props.courseID)
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
})

export function mapStateToProps ({ entities }: AppState, { courseID, url }: OwnProps): StateProps {
  let courseName = ''
  if (entities &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].course) {
    courseName = entities.courses[courseID].course.name
  }
  const page = entities.pages && entities.pages[url] && entities.pages[url].data
  return {
    page,
    courseName,
  }
}

const Connected = connect(mapStateToProps, Actions)(PageDetails)
export default (Connected: Component<Props, any>)
