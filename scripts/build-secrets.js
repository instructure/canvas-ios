#!/usr/bin/env node
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

/*
Generates Secret Data Assets.

Depends on node
 brew install node

Run this script from the repo root directory
 yarn build-secrets studentPSPDFKitLicense=<value> etc
*/

const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')
const run = (cmd) => execSync(cmd, { stdio: 'inherit' })

for (const secret of process.argv.slice(2)) {
  let [ name, ...value ] = secret.split('=')
  value = value.join('=')

  const paddingSize = Math.ceil(Math.random() * 32)
  let padding = Buffer.alloc(paddingSize + 1)
  for (const offset of padding.keys()) {
    padding[offset] = Math.floor(Math.random() * 256)
  }
  padding[padding.length - 1] = paddingSize

  const mixer = Buffer.from(`${name}+com.instructure.icanvas.Core`, 'utf8')
  let data = Buffer.concat([ Buffer.from(value, 'utf8'), padding ])
  for (const [ offset, element ] of data.entries()) {
    data[offset] = data[offset] ^ mixer[offset % mixer.length]
  }

  const folder = `./Core/Core/Resources/Assets.xcassets/Secrets/${name}.dataset`
  run(`mkdir -p ${folder}`)
  fs.writeFileSync(`${folder}/${name}`, data)
  fs.writeFileSync(`${folder}/Contents.json`, `{
    "info" : {
      "version" : 1,
      "author" : "xcode"
    },
    "data" : [
      {
        "idiom" : "universal",
        "filename" : "${name}"
      }
    ]
  }`)
}
