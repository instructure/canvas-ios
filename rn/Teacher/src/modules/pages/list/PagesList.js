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

import React from 'react'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'
import i18n from 'format-message'

import Screen from '../../../routing/Screen'
import Row from '../../../common/components/rows/Row'
import FeatureRow from '../../../common/components/rows/FeatureRow'
import Images from '../../../images'
import {
  fetchPropsFor,
  PageModel,
  CourseModel,
} from '../../../canvas-api/model-api'
import { alertError } from '../../../redux/middleware/error-handler'
import AccessIcon from '../../../common/components/AccessIcon'
import AccessLine from '../../../common/components/AccessLine'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'
import { isTeacher } from '../../app'
import currentWindowTraits, { type WindowTraits } from '../../../utils/windowTraits'
import localeCompare from '../../../utils/locale-sort'

type Props = {
  courseID: string,
  navigator: Navigator,
  courseColor: string,
  course: ?CourseModel,
  pages: PageModel[],
  isLoading: boolean,
  loadError: ?Error,
  refresh: () => void,
}

type State = {
  selectedPageURL: ?string,
  windowTraits: WindowTraits,
  pages: PageModel[],
}

export class PagesList extends React.Component<Props, State> {
  frontPageDidShow: boolean = false
  state = {
    selectedPageURL: null,
    windowTraits: currentWindowTraits(),
    pages: this.prepareList(this.props.pages),
  }

  componentWillMount () {
    this.handleTraitChange()
  }

  componentWillReceiveProps ({ loadError, pages }: Props) {
    if (loadError && loadError !== this.props.loadError) alertError(loadError)
    if (pages !== this.props.pages) {
      this.setState({ pages: this.prepareList(pages) })
    }
  }

  prepareList (pages: PageModel[]) {
    return pages.slice().sort((a, b) => {
      if (a.isFrontPage) return -1
      if (b.isFrontPage) return 1
      return localeCompare(a.title, b.title)
    })
  }

  handleTraitChange = () => {
    this.props.navigator.traitCollection(traits => {
      if ( // switched to split screen, re-evaluate showing front page
        this.state.windowTraits.horizontal === 'compact' &&
        traits.window.horizontal !== 'compact'
      ) {
        this.frontPageDidShow = false
      }
      this.setState({ windowTraits: traits.window })
    })
  }

  select = (url: string) => {
    const route = `/courses/${this.props.courseID}/pages/${url}`
    this.props.navigator.show(route, { modal: false })
    if (this.state.windowTraits.horizontal !== 'compact') {
      this.setState({ selectedPageURL: url })
    }
  }

  addPage = () => {
    const { courseID, navigator } = this.props
    navigator.show(`/courses/${courseID}/pages/new`, {
      modal: true,
      modalPresentationStyle: 'formsheet',
    })
  }

  showFrontPage () {
    const { course, courseColor, courseID, pages, navigator } = this.props
    const { windowTraits } = this.state
    if (
      !this.frontPageDidShow &&
      windowTraits.horizontal !== 'compact' &&
      course != null &&
      pages.length > 0 && !this.props.navigator.isModal
    ) {
      this.frontPageDidShow = true
      const frontPage = pages.find(page => page.isFrontPage)
      if (frontPage) {
        this.select(frontPage.url)
      } else {
        navigator.show(`/courses/${courseID}/placeholder`, {}, {
          courseColor,
          course: course.raw,
        })
      }
    }
  }

  render () {
    this.showFrontPage()
    const { course, courseColor, isLoading, refresh } = this.props
    return (
      <Screen
        navBarColor={courseColor}
        navBarStyle='dark'
        title={i18n('Pages')}
        subtitle={course && course.name || undefined}
        onTraitCollectionChange={this.handleTraitChange}
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
            data={this.state.pages}
            extraData={this.state}
            renderItem={this.renderRow}
            keyExtractor={PageModel.keyExtractor}
            testID='pages.list.list'
            refreshing={isLoading}
            onRefresh={refresh}
            ListEmptyComponent={isLoading ? null : (
              <ListEmptyComponent
                title={i18n('There are no pages to display.')}
              />
            )}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item: page, index }: { item: PageModel, index: number }) => {
    if (page.isFrontPage) {
      return (
        <FeatureRow
          title={i18n('Front Page')}
          subtitle={page.title}
          testID='pages.list.front-page-row'
          identifier={page.url}
          onPress={this.select}
          disclosureIndicator
        />
      )
    }

    const { courseColor } = this.props
    const { selectedPageURL } = this.state

    const icon = (
      <View style={styles.rowIcon}>
        <AccessIcon
          entry={page.raw}
          tintColor={courseColor}
          image={Images.course.pages}
        />
      </View>
    )
    return (
      <View>
        <Row
          title={page.title}
          subtitle={i18n("{ date, date, 'MMM d'} at { date, time, short }", {
            date: page.createdAt,
          })}
          border='bottom'
          height='auto'
          disclosureIndicator
          testID={`pages.list.page.row-${index}`}
          identifier={page.url}
          onPress={this.select}
          renderImage={() => icon}
          selected={selectedPageURL === page.url}
        />
        <AccessLine visible={page.published} />
      </View>
    )
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

export default fetchPropsFor(PagesList, ({ courseID }, api) => ({
  courseColor: api.getCourseColor(courseID),
  course: api.getCourse(courseID),
  pages: api.getPages('courses', courseID).list,
}))
