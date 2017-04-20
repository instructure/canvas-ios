// @flow

const RealComponent = require.requireActual('PickerIOS')
const React = require('React')
export default class PickerIOS extends React.Component {
  render () {
    return React.createElement('PickerIOS', this.props, this.props.children)
  }
}
PickerIOS.Item = props => React.createElement('Item', props, props.children)
PickerIOS.propTypes = RealComponent.propTypes
