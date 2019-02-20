#!/usr/bin/env node
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

  const folder = `./Core/Core/Assets.xcassets/Secrets/${name}.dataset`
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
