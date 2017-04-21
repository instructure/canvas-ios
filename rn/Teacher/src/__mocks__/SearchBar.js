// @flow

const RealComponent = require.requireActual('react-native-search-bar')
const React = require('React')
export default class SearchBar extends React.Component {
  render () {
    return React.createElement('SearchBar', this.props, this.props.children)
  }
}
SearchBar.propTypes = RealComponent.propTypes
