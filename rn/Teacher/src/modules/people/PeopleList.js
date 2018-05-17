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
import {
  View,
  FlatList,
  StyleSheet,
  ActionSheetIOS,
} from 'react-native'
import { connect } from 'react-redux'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import Row from '../../common/components/rows/Row'
import Avatar from '../../common/components/Avatar'
import { default as TypeAheadSearch, type TypeAheadSearchResults } from '../../common/TypeAheadSearch'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import { Heading1 } from '../../common/text'
import { LinkButton } from '../../common/buttons'
import { httpClient, isAbort } from '../../canvas-api'
import RowSeparator from '../../common/components/rows/RowSeparator'
import { isRegularDisplayMode } from '../../routing/utils'
import type { TraitCollection } from '../../routing/Navigator'

export type Props = NavigationProps & {
  onSelect: (selected: AddressBookResult[]) => void,
  context: string,
  name: string,
  courseColor: string,
  course: Course,
  showFilter?: boolean,
  courseID: string,
}

function isBranch (id: string): boolean {
  return id.startsWith('course') ||
    id.startsWith('group') ||
    id.startsWith('section')
}

export function handleSyntheticContext (params: {[string]: any}): {[string]: any} {
  let mutableParams = { ...params }
  if (mutableParams.mashGroupsIntoMembers === undefined || mutableParams.mashGroupsIntoMembers !== undefined && mutableParams.mashGroupsIntoMembers === false) {
    mutableParams.synthetic_contexts = 1
  } else if (mutableParams.synthetic_contexts !== undefined) {
    delete mutableParams.synthetic_contexts
  }

  if (mutableParams.mashGroupsIntoMembers !== undefined) delete mutableParams.mashGroupsIntoMembers

  return mutableParams
}

export async function fetch (url: string, params: { [string]: any } = {}, callback: TypeAheadSearchResults): Promise<void> {
  const options:{[string]: any} = {
    params: handleSyntheticContext(params),
  }

  try {
    let response = await httpClient().get(url, options)
    callback(response.data, null)
  } catch (thrown) {
    if (!isAbort(thrown)) {
      callback(null, thrown.message)
    }
  }
}

function localizedRoles (): { [string]: string } {
  return {
    'teacher': i18n('Teacher'),
    'student': i18n('Student'),
    'observer': i18n('Observer'),
    'ta': i18n('TA'),
    'designer': i18n('Designer'),
  }
}

export class PeopleList extends Component<Props, any> {
  typeAhead: TypeAheadSearch

  constructor (props: Props) {
    super(props)

    this.state = {
      searchResults: [],
      searchString: '',
      error: null,
      pending: false,
      context: this.props.context || this._courseContext(),
      filters: [],
      showFilter: this.props.showFilter === undefined ? true : this.props.showFilter,
      marginBottom: global.tabBarHeight,
      selectedRowID: null,
    }
  }

  componentDidMount () {
    const context = this._courseContext()
    this._fetchFilterOptions(context, this._fetchInitialActionSheetOptionsHandler)
  }

  componentWillMount () {
    this._onTraitCollectionChange()
  }

  _onTraitCollectionChange () {
    this.props.navigator.traitCollection((traits) => { this._traitCollectionDidChange(traits) })
  }

  _traitCollectionDidChange (traits: TraitCollection) {
    this.setState({ isRegularScreenDisplayMode: isRegularDisplayMode(traits) })
  }

  _courseContext = (): string => {
    if (this.props.courseID) {
      return `course_${this.props.courseID}`
    }
    return ''
  }

  _fetchFilterOptions (context: string, handler: Function, showAll: boolean = false) {
    const endpoint = '/search/recipients'
    let params = {
      context,
      search: '',
      per_page: 50,
      mashGroupsIntoMembers: showAll,
    }
    fetch(endpoint, params, handler)
  }

  _queryChanged = (query: string) => {
    this.setState({ searchString: query })
  }

  _requestStarted = () => {
    this.setState({
      pending: true,
    })
  }

  _groupFetchHandler = (results: ?AddressBookResult[], error: ?string) => {
    this._fetchInitialActionSheetOptionsHandler(results, error)
    this._chooseFilter()
  }

  _fetchInitialActionSheetOptionsHandler = (results: ?AddressBookResult[], error: ?string) => {
    let existingOptions = this.state.filters || []
    if (results) {
      existingOptions.push(results)
    }
    this.setState({
      filters: existingOptions,
    })
  }

  _requestFinished = (results: ?AddressBookResult[], error: ?string) => {
    this.setState({
      searchResults: results || [],
      pending: false,
      error,
    })
  }

  _nextRequestFinished = (results: ?AddressBookResult[], error: ?string) => {
    this.setState({
      searchResults: this.state.searchResults.concat(results),
      pending: false,
      error,
    })
  }

  _buildParams = (query: string) => ({
    context: this.state.context,
    search: query,
    per_page: 15,
    type: 'user',
    skip_visibility_checks: 1,
  })

  _onSelectItem = (item: AddressBookResult) => {
    if (isBranch(item.id)) {
      this.showItem(item)
      return
    }

    this.setState({ selectedRowID: item.id })

    this.props.navigator.show(
      `/courses/${this.props.course.id}/users/${item.id}`,
      undefined,
      { modal: false }
    )
  }

  _mapCourseMembership = (item) => {
    const courses = item.common_courses || {}
    const values = new Set()
    Object.keys(courses).forEach((key) => {
      let memberships = courses[key]
      memberships.forEach((role) => {
        role = role.substring(0, role.indexOf('Enrollment'))
        let localizedRole = localizedRoles()[role.toLowerCase()] || role
        values.add(localizedRole)
      })
    })
    return [...values].join()
  }

  keyExtractor (item: AddressBookResult) {
    return item.id
  }

  _isRowSelected (item: AddressBookResult): boolean {
    if (this.state && this.state.selectedRowID) {
      return this.state.isRegularScreenDisplayMode && this.state.selectedRowID === item.id
    }

    return false
  }

  _renderRow = ({ item, index }) => {
    let border = 'bottom'
    if (index === 0) {
      border = 'both'
    }

    const selected = this._isRowSelected(item)
    const membership = this._mapCourseMembership(item)
    const avatarName = item.id.startsWith('branch') ? i18n('All') : item.name
    const avatar = (<View style={styles.avatar}>
      <Avatar avatarURL={item.avatar_url} userName={avatarName}/>
    </View>)

    return <Row title={item.full_name}
      subtitle={membership}
      border={border}
      renderImage={() => avatar}
      testID={item.id}
      disclosureIndicator={isBranch(item.id)}
      onPress={() => this._onSelectItem(item)}
      selected={selected} />
  }

  _renderSearchBar = () => (
    <View>
      <TypeAheadSearch
        ref={(r: any) => { this.typeAhead = r }}
        endpoint='/search/recipients'
        parameters={this._buildParams}
        onRequestStarted={this._requestStarted}
        onRequestFinished={this._requestFinished}
        onNextRequestFinished={this._nextRequestFinished}
        onChangeText={this._queryChanged}
        defaultQuery=''
      />
      { this.state.showFilter &&
        <View style={styles.headerContainer}>
          <Heading1>{i18n('All People')}</Heading1>
          {this._renderFilterButton()}
        </View>
      }
    </View>
  )

  _renderFilterButton = () => {
    let title = i18n('Filter')
    let accessibilityLabel = i18n('Filter People')
    let onPress = this._chooseFilter

    return (<LinkButton
      testID='peopleList.filterBy'
      onPress={onPress}
      style={styles.filterButton}
      accessibilityLabel={ accessibilityLabel }
    >
      { title }
    </LinkButton>)
  }

  _currentFilter = () => {
    if (this.state.filters && this.state.filters.length > 0) {
      return this.state.filters[this.state.filters.length - 1]
    }
    return []
  }

  _chooseFilter = () => {
    let filterOptions = this._currentFilter()
    const options = filterOptions.map((item) => item.name)
    options.push(i18n('Cancel'))
    ActionSheetIOS.showActionSheetWithOptions({
      options,
      cancelButtonIndex: options.length - 1,
      title: i18n('Filter by:'),
    }, this._updateFilter)
  }

  _isSectionOrGroup (item: string): boolean {
    return item.endsWith('sections') || item.endsWith('groups')
  }

  _updateFilter = (index: number) => {
    let filterOptions = this._currentFilter()
    let resetFilter = true
    if (index !== filterOptions.length) {
      let item = filterOptions[index]
      if (isBranch(item.id) && this._isSectionOrGroup(item.id)) {
        this._fetchFilterOptions(item.id, this._groupFetchHandler, false)
        resetFilter = false
      } else {
        this._onSelectItem(item)
      }
    }

    if (resetFilter && this.state.filters.length > 1) {
      this.setState({
        filters: [this.state.filters[0]],
      })
    }
  }

  _renderComponent = () => {
    const searchBar = this._renderSearchBar()
    const empty = <ListEmptyComponent title={i18n('No results')} />
    return (<View style={styles.container}>
      <FlatList
        keyboardDismissMode='on-drag'
        data={this.state.searchResults}
        renderItem={this._renderRow}
        ListHeaderComponent={searchBar}
        ListEmptyComponent={this.state.pending ? null : empty}
        refreshing={this.state.pending}
        onEndReached={() => this.typeAhead.next()}
        ItemSeparatorComponent={RowSeparator}
        keyExtractor={this.keyExtractor}
      />
    </View>)
  }

  render () {
    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        drawUnderNavBar
        title={this.props.name || i18n('People')}
        subtitle={(this.props.course && this.props.course.name) || ''}
        onTraitCollectionChange={this._onTraitCollectionChange.bind(this)}
      >
        { this._renderComponent() }
      </Screen>
    )
  }

  showItem (item: AddressBookResult) {
    this.props.navigator.show(`/courses/${this.props.course.id}/users`, {}, {
      onSelect: this.props.onSelect,
      context: item.id,
      name: item.name,
      showFilter: false,
    })
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  avatar: {
    width: 40,
    height: 40,
    marginRight: global.style.defaultPadding,
  },
  filterButton: {
    marginBottom: 1,
  },
  headerContainer: {
    paddingTop: global.style.defaultPadding,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding / 2,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
  },
})

type RoutingParams = {
  +courseID: string,
}

export type PeopleListDataProps = {
  +course: ?Course,
  +courseColor: ?string,
}

export function mapStateToProps (state: AppState, { courseID }: RoutingParams): PeopleListDataProps {
  let courseState = state.entities.courses[courseID]
  let course
  let courseColor
  if (courseState) {
    course = courseState.course
    courseColor = courseState.color
  }

  return {
    course,
    courseColor,
  }
}

const Connected = connect(mapStateToProps, {})(PeopleList)
export default (Connected: Component<Props, any>)
