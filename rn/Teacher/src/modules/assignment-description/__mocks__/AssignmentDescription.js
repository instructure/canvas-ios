/* @flow */

const Unconnected: any = require.requireActual('../AssignmentDescription').AssignmentDescription

export const AssignmentDescription: typeof Unconnected = Unconnected
export default Unconnected

Unconnected.prototype.getWrappedInstance = function () { return this }
