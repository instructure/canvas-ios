import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import { getSession } from '../../api/session.js'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import Row from '../../common/components/rows/Row'
import SearchBar from 'react-native-search-bar'
import { searchAddressBook } from '../../api/canvas-api/addressBook'
import axios from 'axios'
import Avatar from '../../common/components/Avatar'

export type AddressBookDataProps = {
  courseID?: string,
}

export type AddressBookNavigationProps = {
  onSelect: (selected: AddressBookResult[]) => void,
  onCancel?: () => void,
  navigator: Navigator,
}

export class AddressBook extends Component {

  cancelSearch: Function

  constructor (props: AddressBookDataProps) {
    super(props)
    this.state = {
      searchResults: [],
      error: null,
    }
  }

  _searchFor = (searchString: string) => {
    if (this.cancelSearch) {
      this.cancelSearch()
    }

    let session = getSession()
    let senderID = session ? session.user.id : null
    const search = searchAddressBook(senderID, searchString)
    const promise = search.promise
    this.cancelSearch = search.cancel
    promise.then((response) => {
      this.setState({
        searchResults: response.data,
        error: null,
      })
    }).catch((thrown) => {
      if (!axios.isCancel(thrown)) {
        this.setState({
          error: thrown.message,
        })
      }
    })
  }

  _onSelectItem = (item: AddressBookResult) => {
    this.props.onSelect([item])
  }

  _onCancel = () => {
    if (this.props.onCancel) {
      this.props.onCancel()
    } else {
      this.props.navigator.dismiss()
    }
  }

  _renderRow = ({ item, index }) => {
    let border = 'bottom'
    if (index === 0) {
      border = 'both'
    }
    const avatar = (<View style={styles.avatar}>
                      <Avatar avatarURL={item.avatar_url} userName={item.name}/>
                    </View>)

    return <Row title={item.name}
                border={border}
                renderImage={() => avatar}
                identifier={item}
                onPress={this._onSelectItem} />
  }

  _renderSearchBar = () => {
    return <SearchBar
            ref={ (c) => { this.searchBar = c }}
            onChangeText={this._searchFor}
            onSearchButtonPress={() => this.searchBar.unFocus()}
            onCancelButtonPress={() => this.searchBar.unFocus()}
            />
  }

  _renderComponent = () => {
    const searchBar = this._renderSearchBar()
    return (<View style={styles.container}>
              <FlatList
                data={this.state.searchResults}
                renderItem={this._renderRow}
                ListHeaderComponent={searchBar}
              />
            </View>)
  }

  render () {
    return (
      <Screen
        navBarColor='#fff'
        navBarStyle='light'
        drawUnderNavBar={true}
        title={i18n('Add Recipient')}
        leftBarButtons={[{
          title: i18n('Cancel'),
          testID: 'address-book.cancel',
          action: this._onCancel,
        }]}
      >
        { this._renderComponent() }
      </Screen>
    )
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
})

export function mapStateToProps (state: AppState): AddressBookDataProps {
  return {}
}

const Connected = connect(mapStateToProps, {})(AddressBook)
export default (Connected: Component<any, Props, any>)
