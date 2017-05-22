// @flow

const RealComponent = require.requireActual('../Screen')
const React = require('React')
export default class Screen extends React.Component {
  render () {
    return React.createElement('Screen', this.props, this.props.children)
  }
}
Screen.propTypes = RealComponent.propTypes
