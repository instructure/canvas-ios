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
import FeatureRow from '../../../common/components/rows/FeatureRow'
import Actions from './actions'
import Images from '../../../images'
import { getPages } from '../../../canvas-api'
import { alertError } from '../../../redux/middleware/error-handler'
import AccessIcon from '../../../common/components/AccessIcon'
import localeSort from '../../../utils/locale-sort'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'
import { isTeacher } from '../../app'
import currentWindowTraits from '../../../utils/windowTraits'

type StateProps = AsyncState & {
  pages: Page[],
  courseName: string,
  courseColor: ?string,
  course: ?Course,
}

type OwnProps = {
  courseID: string,
  pending: boolean,
  refreshing: boolean,
}

export type Props = OwnProps & StateProps & typeof Actions & NavigationProps

export class PagesList extends Component<Props, any> {
  static defaultProps = {
    getPages,
  }

  frontPageDidShow: boolean = false
  state = {
    windowTraits: currentWindowTraits(),
    selectedPageURL: null,
    pending: false,
  }

  componentWillMount () {
    this.refresh()
    this.props.navigator.traitCollection((traits) => {
      this.setState({ windowTraits: traits.window })
    })
  }

  render () {
    this.showFrontPage()
    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        title={i18n('Pages')}
        subtitle={this.props.courseName}
        onTraitCollectionChange={this.onTraitCollectionChange}
        leftBarButtons={this.props.navigator.isModal && [
          {
            title: i18n('Done'),
            testID: 'pages.list.dismiss.button',
            action: this.props.navigator.dismiss,
          },
        ]}
        rightBarButtons={isTeacher() && [
          {
            image: Images.add,
            testID: 'pages.list.add.button',
            accessibilityLabel: i18n('New Page'),
            action: this.addPage,
          },
        ]}
      >
        <View style={styles.container}>
          <FlatList
            data={this.props.pages}
            renderItem={this.renderRow}
            keyExtractor={(item, index) => item.url}
            testID='pages.list.list'
            refreshing={this.state.pending}
            onRefresh={this.refresh}
            ListEmptyComponent={
              this.state.pending && !this.props.refreshing ? null
              : <ListEmptyComponent title={i18n('There are no pages to display.')} />
            }
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: Page, index: number }) => {
    if (item.front_page) {
      return (
        <FeatureRow
          title={i18n('Front Page')}
          subtitle={item.title}
          testID='pages.list.front-page-row'
          onPress={this.selectPage(item)}
          disclosureIndicator
        />
      )
    }

    let icon = (
      <View style={styles.rowIcon}>
        <AccessIcon
          entry={item}
          tintColor={this.props.courseColor}
          image={Images.course.pages}
          showAccessIcon={isTeacher()}
        />
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
        selected={this.state.selectedPageURL === item.url}
      />
    )
  }

  selectPage (page: Page) {
    const route = `/courses/${this.props.courseID}/pages/${page.url}`
    return () => {
      this.props.navigator.show(route, { modal: false })
      if (this.state.windowTraits.horizontal !== 'compact') {
        this.setState({ selectedPageURL: page.url })
      }
    }
  }

  refresh = async () => {
    this.setState({ pending: true })
    try {
      // $FlowFixMe
      const { data } = await this.props.getPages(this.props.courseID)
      this.props.refreshedPages(data, this.props.courseID)
    } catch (error) {
      alertError(error)
    }
    this.setState({ pending: false })
  }

  addPage = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/pages/new`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  onTraitCollectionChange = () => {
    this.props.navigator.traitCollection((traits) => {
      if (
        this.state.windowTraits.horizontal === 'compact' &&
        traits.window.horizontal !== 'compact'
      ) {
        this.frontPageDidShow = false
      }
      this.setState({ windowTraits: traits.window })
    })
  }

  showFrontPage () {
    if (this.frontPageDidShow || !this.props.course || !this.props.pages.length) return
    this.frontPageDidShow = true
    if (this.state.windowTraits.horizontal !== 'compact') {
      const frontPage = this.props.pages.find(({ front_page: frontPage }) => frontPage)
      if (frontPage) {
        Promise.resolve().then(() => this.selectPage(frontPage)())
      } else {
        this.props.navigator.show(`/courses/${this.props.courseID}/placeholder`, {}, { courseColor: this.props.courseColor, course: this.props.course })
      }
    }
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

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps) {
  let pages = []
  let courseName = ''
  let courseColor = null
  let course = null
  if (entities &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].pages) {
    const courseEntity = entities.courses[courseID]
    course = courseEntity.course
    courseName = course && course.name
    courseColor = courseEntity.color
    const refs = courseEntity.pages.refs
    pages = refs
      .map(ref => entities.pages[ref].data)
      .sort((a, b) => localeSort(a.title, b.title))
      .sort((a, b) => b.front_page - a.front_page)
  }
  return {
    pages,
    courseName,
    courseColor,
    course,
  }
}

const Connected = connect(mapStateToProps, Actions)(PagesList)
export default Connected
