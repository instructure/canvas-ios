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

/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'
import i18n from 'format-message'

import Screen from '../../../routing/Screen'
import Row from '../../../common/components/rows/Row'
import Actions from './actions'
import Images from '../../../images'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import { getPages } from '../../../canvas-api'
import { alertError } from '../../../redux/middleware/error-handler'
import PublishedIcon from '../../../common/components/PublishedIcon'
import { Text } from '../../../common/text'

type StateProps = AsyncState & {
  pages: Page[],
  courseName: string,
  courseColor: ?string,
}

type OwnProps = {
  courseID: string,
}

export type Props = OwnProps & StateProps & typeof Actions & NavigationProps

export class PagesList extends Component<Props, any> {
  static defaultProps = {
    getPages,
  }

  constructor (props: Props) {
    super(props)

    this.state = {
      pending: false,
    }
  }

  componentWillMount () {
    this.refresh()
  }

  render () {
    return (
      <Screen
        navBarStyle='dark'
        title={i18n('Pages')}
        subtitle={this.props.courseName}
      >
        <View style={styles.container}>
          <FlatList
            data={this.props.pages}
            renderItem={this.renderRow}
            keyExtractor={(item, index) => item.url}
            testID='pages.list.list'
            refreshing={this.state.pending}
            onRefresh={this.refresh}
            ItemSeparatorComponent={RowSeparator}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: Page, index: number }) => {
    let icon = (
      <View style={styles.rowIcon}>
        <PublishedIcon published={item.published} tintColor={this.props.courseColor} image={Images.course.pages} />
      </View>
    )
    return (
      <Row
        title={item.title}
        subtitle={i18n("{ date, date, 'MMM d'} at { date, time, short }", { date: new Date(item.created_at) })}
        border='bottom'
        height='auto'
        disclosureIndicator={true}
        testID={`pages.list.page.row-${index}`}
        onPress={this.selectPage(item)}
        renderImage={() => icon}
        accessories={item.front_page && (
          <View style={styles.rowFrontPagePill}>
            <Text style={styles.rowFrontPagePillText} testID='pages.list.front-page.pill'>Front Page</Text>
          </View>
        )}
      />
    )
  }

  selectPage (page: Page) {
    const route = `/courses/${this.props.courseID}/pages/${page.url}`
    return () => this.props.navigator.show(route, { modal: false })
  }

  refresh = async () => {
    this.setState({ pending: true })
    try {
      const { data } = await this.props.getPages(this.props.courseID)
      this.props.refreshedPages(data, this.props.courseID)
    } catch (error) {
      alertError(error)
    }
    this.setState({ pending: false })
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  rowIcon: {
    alignSelf: 'flex-start',
  },
  rowFrontPagePill: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    backgroundColor: '#73818C',
    borderRadius: 4,
  },
  rowFrontPagePillText: {
    color: 'white',
    fontSize: 14,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps): StateProps {
  let pages = []
  let courseName = ''
  let courseColor = null
  if (entities &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].pages) {
    const course = entities.courses[courseID]
    const refs = course.pages.refs
    if (course.course) {
      courseName = course.course.name
      courseColor = course.color
    }
    pages = refs
      .map(ref => entities.pages[ref].data)
      .sort((a, b) => a.title.toLowerCase() > b.title.toLowerCase() ? 1 : -1)
  }
  return {
    pages,
    courseName,
    courseColor,
  }
}

const Connected = connect(mapStateToProps, Actions)(PagesList)
export default (Connected: Component<Props, any>)
