// @flow

const RealComponent = require.requireActual('../RichTextToolbar')
const React = require('React')
export default class RichTextToolbar extends React.Component {
  render () {
    return React.createElement('RichTextToolbar', this.props, this.props.children)
  }
}
RichTextToolbar.propTypes = RealComponent.propTypes

