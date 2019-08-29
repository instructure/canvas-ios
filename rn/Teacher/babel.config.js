//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */
module.exports = {
  presets: [ 'module:metro-react-native-babel-preset' ],
  plugins: [
    [ 'module-resolver', {
      root: [ './src' ],
      alias: {
        '@modules': './src/modules',
        '@test': './test',
        '@common': './src/common',
        '@images': './src/images',
        '@templates': './src/__templates__',
        '@mocks': './src/__mocks__',
        '@canvas-api': './src/canvas-api',
        '@canvas-api2': './src/canvas-api-v2',
        '@utils': './src/utils',
        '@redux': './src/redux',
        '@routing': './src/routing',
      },
    } ],
    '@babel/plugin-proposal-optional-chaining',
    '@babel/plugin-proposal-nullish-coalescing-operator',
  ],
  sourceMaps: true,
}
