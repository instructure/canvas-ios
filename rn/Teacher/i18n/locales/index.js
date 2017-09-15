//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

export default ({
  ar: require('./ar.json'),
  da: require('./da.json'),
  de: require('./de.json'),
  'en-AU': require('./en_AU.json'),
  'en-GB': require('./en_GB.json'),
  en: require('./en.json'),
  es: require('./es.json'),
  'fr-CA': require('./fr_CA.json'),
  fr: require('./fr.json'),
  ht: require('./ht.json'),
  ja: require('./ja.json'),
  mi: require('./mi.json'),
  nb: require('./nb.json'),
  nl: require('./nl.json'),
  pl: require('./pl.json'),
  'pt-BR': require('./pt_BR.json'),
  pt: require('./pt.json'),
  ru: require('./ru.json'),
  sv: require('./sv.json'),
  'zh-HK': require('./zh_HK.json'),
  zh: require('./zh.json'),
}: { [string]: { [string]: { message: string, description?: string } } })
