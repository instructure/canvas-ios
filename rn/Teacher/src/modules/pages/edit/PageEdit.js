// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  LayoutAnimation,
  PickerIOS,
  findNodeHandle,
} from 'react-native'
import Screen from '../../../routing/Screen'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { Heading1 } from '../../../common/text'
import RowWithTextInput from '../../../common/components/rows/RowWithTextInput'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowWithDetail from '../../../common/components/rows/RowWithDetail'
import SavingBanner from '../../../common/components/SavingBanner'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import i18n from 'format-message'
import colors from '../../../common/colors'
import { createPage, updatePage } from '../../../canvas-api'
import Actions from '../details/actions'
import { alertError } from '../../../redux/middleware/error-handler'

const PickerItem = PickerIOS.Item

type OwnProps = {
  url: ?string,
  courseID: string,
}

type StateProps = {
  title: ?string,
  body: ?string,
  editing_roles: string,
  published: boolean,
  front_page: boolean,
}

export type Props = OwnProps & StateProps & NavigationProps & typeof Actions & {
  createPage: typeof createPage,
  updatePage: typeof updatePage,
}

type State = {
  title: ?string,
  body: ?string,
  editing_roles: string,
  published: boolean,
  front_page: boolean,
  editingRolesPickerShown: boolean,
  pending: boolean,
}

function editingRoles () {
  return {
    'teachers': i18n('Only teachers'),
    'students,teachers': i18n('Teachers and students'),
    'public': i18n('Anyone'),
  }
}

function convertEditingRolesFromAPI (editingRoles: string) {
  const array = editingRoles.split(',').map(r => r.trim())
  if (array.includes('public')) return 'public'
  if (array.includes('students')) return 'students,teachers'
  return 'teachers'
}

export class PageEdit extends Component<Props, State> {
  scrollView: ?KeyboardAwareScrollView

  static defaultProps = {
    createPage,
    updatePage,
  }

  state: State = {
    title: this.props.title,
    body: this.props.body,
    editing_roles: this.props.editing_roles,
    published: this.props.published,
    front_page: this.props.front_page,
    editingRolesPickerShown: false,
    pending: false,
  }

  render () {
    const title = this.isEdit() ? i18n('Edit') : i18n('New')
    return (
      <Screen
        title={i18n('{title} Page', { title })}
        rightBarButtons={[
          {
            title: i18n('Done'),
            testID: 'pages.edit.doneButton',
            style: 'done',
            action: this.done,
          },
        ]}
        leftBarButtons={[
          {
            title: i18n('Cancel'),
            testID: 'pages.edit.cancelButton',
            style: 'cancel',
            action: this.cancel,
          },
        ]}
      >
        <View style={{ flex: 1 }}>
          { this.state.pending && <SavingBanner /> }
          <KeyboardAwareScrollView
            style={style.container}
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
            ref={(r) => { this.scrollView = r }}
            keyboardDismissMode={'on-drag'}
          >
            <Heading1 style={style.heading}>{i18n('Title')}</Heading1>
            <RowWithTextInput
              defaultValue={this.state.title}
              border='both'
              onChangeText={this.updateValue('title')}
              identifier='pages.edit.titleInput'
              placeholder={i18n('Add title')}
              onFocus={this._scrollToInput}
            />

            <Heading1 style={style.heading}>{i18n('Description')}</Heading1>
            <View
              style={style.description}
            >
              <RichTextEditor
                onChangeValue={this.updateValue('body')}
                defaultValue={this.props.body}
                showToolbar='always'
                keyboardAware={false}
                scrollEnabled={true}
                contentHeight={150}
                placeholder={i18n('Add description')}
                navigator={this.props.navigator}
              />
            </View>

            <Heading1 style={style.heading}>{i18n('Details')}</Heading1>
            { !this.state.front_page &&
              <RowWithSwitch
                title={i18n('Publish')}
                border='bottom'
                value={this.state.published}
                onValueChange={this.updateValue('published')}
                testID='pages.edit.published.row'
                identifier='pages.edit.published.switch'
              />
            }
            { !this.props.front_page && this.state.published &&
              <RowWithSwitch
                title={i18n('Set as Front Page')}
                border='both'
                value={this.state.front_page}
                onValueChange={this.updateValue('front_page')}
                testID='pages.edit.front_page.row'
                identifier='pages.edit.front_page.switch'
              />
            }
            <RowWithDetail
              title={i18n('Can Edit')}
              detailSelected={this.state.editingRolesPickerShown}
              detail={editingRoles()[this.state.editing_roles]}
              disclosureIndicator={true}
              border='bottom'
              onPress={this.toggleEditingRoles}
              testID='pages.edit.editing_roles.row'
            />
            { this.state.editingRolesPickerShown &&
              <PickerIOS
                selectedValue={this.state.editing_roles}
                onValueChange={this.updateValue('editing_roles')}
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
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }

  done = async () => {
    const {
      title,
      body,
      editing_roles,
      published,
      front_page: frontPage,
    } = this.state
    const parameters = {
      title,
      body,
      editing_roles,
      published: frontPage || published,
      front_page: frontPage,
    }
    this.setState({ pending: true })
    try {
      let result
      if (this.props.url) {
        result = await this.props.updatePage(this.props.courseID, this.props.url, parameters)
      } else {
        result = await this.props.createPage(this.props.courseID, parameters)
      }
      this.props.refreshedPage(result.data, this.props.courseID)
      this.setState({ pending: false })
      this.props.navigator.dismiss()
    } catch (error) {
      this.setState({ pending: false })
      alertError(error)
    }
  }

  cancel = () => {
    this.props.navigator.dismiss()
  }

  updateValue (property: string): Function {
    return (value) => {
      this.updateValues({ [property]: value })
    }
  }

  updateValues (values: Object) {
    LayoutAnimation.easeInEaseOut()
    this.setState({ ...values })
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
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  heading: {
    color: colors.darkText,
    marginLeft: global.style.defaultPadding,
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding / 2,
  },
  description: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.seperatorColor,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
    backgroundColor: 'white',
    height: 200,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, url }: OwnProps): StateProps {
  let page
  if (entities &&
    entities.courses &&
    entities.courses[courseID]) {
    const course = entities.courses[courseID]
    page = course.pages.refs
      .map(r => entities.pages[r])
      .filter(p => p)
      .map(p => p.data)
      .find(p => p.url === url)
  }
  const {
    title,
    body,
    editing_roles: editingRoles,
    published,
    front_page,
  } = (page || {})
  return {
    title,
    body,
    editing_roles: convertEditingRolesFromAPI(editingRoles || 'teachers'),
    published: Boolean(published),
    front_page: Boolean(front_page),
  }
}

let Connected = connect(mapStateToProps, Actions)(PageEdit)
export default (Connected: *)
