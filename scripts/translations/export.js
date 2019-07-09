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

const program = require('commander')
const { spawn } = require('child_process')
const { createReadStream, readFileSync, writeFileSync } = require('fs')
const S3 = require('aws-sdk/clients/s3')
const projects = require('./projects.json')

program
  .version(require('../../package.json').version)
  .option('-s, --skipPush', 'Skip pushing to S3')
  .option('-p, --project [name]', 'Export only a specific project')

program.on('--help', () => {
  console.log(`
  Environment Variables:

    AWS_ACCESS_KEY_ID      AWS key, required to sync to instructure-translations S3 bucket
    AWS_SECRET_ACCESS_KEY  AWS secret, required to sync to instructure-translations S3 bucket
  \n`)
})
program.parse(process.argv)

if (
  !program.skipPush &&
  (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY)
) {
  program.outputHelp()
  process.exit(1)
}

exportTranslations().catch(err => {
  console.error('Export translations failed: ', err)
  process.exit(2)
})

function run(cmd, args, opts) {
  return new Promise((resolve, reject) => {
    const command = spawn(cmd, args, opts)
    command.on('error', reject)
    command.on('exit', code => {
      if (code === 0) return resolve()
      console.error(command.stderr.toString())
      reject(`${cmd} failed with code ${code}.`)
    })
  })
}

async function exportTranslations() {
  const keysToSkip = ['CFBundleName']
  const toUpload = []
  const localizeInfoPlistOfTheseProjects = ['canvas', 'parent', 'teacher_native']
  for (const project of projects) {
    if (program.project && project.name !== program.project) continue

    if (project.location.endsWith('.xcodeproj')) {
      const outputPath = `scripts/translations/source/${project.name}/`
      console.log(`Exporting ${project.name} at ${project.location} to ${outputPath}`)
      await run('xcodebuild', [
        '-exportLocalizations',
        '-project',
        project.location,
        '-localizationPath',
        outputPath
      ])

      const file = `${outputPath}en.xcloc/Localized Contents/en.xliff`
      let xml = readFileSync(file, 'utf8')
      if(!localizeInfoPlistOfTheseProjects.includes(project.name)) {
          xml = xml.replace(/<file[^>]*Info\.plist[\s\S]*?<\/file>\s*/g, '')
      }
      keysToSkip.forEach((key) => {
        const regex = new RegExp(`<trans-unit id=\"${key}\"[\\\s\\\S]*?<\/trans-unit>\\s`, 'g')
        xml = xml.replace(regex, '')
      })
      writeFileSync(file, xml, 'utf8')
      toUpload.push({ from: file, to: `${project.name}.xliff` })
    } else {
      console.log(`Exporting ${project.name} at ${project.location}`)
      await run('yarn', [], { cwd: `${project.location}/../..` }) // install dependencies
      await run('yarn', ['extract-strings'], { cwd: `${project.location}/../..` })
      toUpload.push({ from: `${project.location}/en.json`, to: `${project.name}.json` })
    }
  }

  if (!program.skipPush) {
    const Bucket = 'instructure-translations'
    const s3 = new S3({ region: 'us-east-1' })
    await Promise.all(toUpload.map(({ from, to }) => {
      console.log(`Uploading ${from} to s3://instructure-translations/sources/canvas-ios/en/${to}`)
      return s3.putObject({ Bucket, Key: `sources/canvas-ios/en/${to}`, Body: createReadStream(from) })
        .promise()
    }))
  }

  console.log('Finished!')
}
