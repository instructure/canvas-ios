//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

//
//  StripHTMLTags.swift
//  WhizzyWig
//
//  Created by Derrick Hathaway onCharacter(UnicodeScalar(5))/8/15.
//
//

import Foundation

public extension String {
    public func stringByStrippingHTML() -> String {
        var str = self.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: [.regularExpression, .caseInsensitive], range: nil)
        str = str.replacingOccurrences(of: "</*p[^>]*>", with: "\n", options: [.regularExpression, .caseInsensitive], range: nil)
        str = str.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        for (escaped, char) in completeMap {
            str = str.replacingOccurrences(of: escaped, with: String([char]), options: .caseInsensitive, range: nil)
        }
        return str
    }
}

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
private let asciiEscapeMap: [(String, Character)] = [
    // A.2.2. Special characters
    ( "&quot;",Character(UnicodeScalar(34) )),
    ( "&amp;",Character(UnicodeScalar(38) )),
    ( "&apos;",Character(UnicodeScalar(39) )),
    ( "&lt;",Character(UnicodeScalar(60) )),
    ( "&gt;",Character(UnicodeScalar(62) )),
    
    // A.2.1. Latin-1 characters
    ( "&nbsp;",Character(UnicodeScalar(160) )),
    ( "&iexcl;",Character(UnicodeScalar(161) )),
    ( "&cent;",Character(UnicodeScalar(162) )),
    ( "&pound;",Character(UnicodeScalar(163) )),
    ( "&curren;",Character(UnicodeScalar(164) )),
    ( "&yen;",Character(UnicodeScalar(165) )),
    ( "&brvbar;",Character(UnicodeScalar(166) )),
    ( "&sect;",Character(UnicodeScalar(167) )),
    ( "&uml;",Character(UnicodeScalar(168) )),
    ( "&copy;",Character(UnicodeScalar(169) )),
    ( "&ordf;",Character(UnicodeScalar(170) )),
    ( "&laquo;",Character(UnicodeScalar(171) )),
    ( "&not;",Character(UnicodeScalar(172) )),
    ( "&shy;",Character(UnicodeScalar(173) )),
    ( "&reg;",Character(UnicodeScalar(174) )),
    ( "&macr;",Character(UnicodeScalar(175) )),
    ( "&deg;",Character(UnicodeScalar(176) )),
    ( "&plusmn;",Character(UnicodeScalar(177) )),
    ( "&sup2;",Character(UnicodeScalar(178) )),
    ( "&sup3;",Character(UnicodeScalar(179) )),
    ( "&acute;",Character(UnicodeScalar(180) )),
    ( "&micro;",Character(UnicodeScalar(181) )),
    ( "&para;",Character(UnicodeScalar(182) )),
    ( "&middot;",Character(UnicodeScalar(183) )),
    ( "&cedil;",Character(UnicodeScalar(184) )),
    ( "&sup1;",Character(UnicodeScalar(185) )),
    ( "&ordm;",Character(UnicodeScalar(186) )),
    ( "&raquo;",Character(UnicodeScalar(187) )),
    ( "&frac14;",Character(UnicodeScalar(188) )),
    ( "&frac12;",Character(UnicodeScalar(189) )),
    ( "&frac34;",Character(UnicodeScalar(190) )),
    ( "&iquest;",Character(UnicodeScalar(191) )),
    ( "&Agrave;",Character(UnicodeScalar(192) )),
    ( "&Aacute;",Character(UnicodeScalar(193) )),
    ( "&Acirc;",Character(UnicodeScalar(194) )),
    ( "&Atilde;",Character(UnicodeScalar(195) )),
    ( "&Auml;",Character(UnicodeScalar(196) )),
    ( "&Aring;",Character(UnicodeScalar(197) )),
    ( "&AElig;",Character(UnicodeScalar(198) )),
    ( "&Ccedil;",Character(UnicodeScalar(199) )),
    ( "&Egrave;",Character(UnicodeScalar(200) )),
    ( "&Eacute;",Character(UnicodeScalar(201) )),
    ( "&Ecirc;",Character(UnicodeScalar(202) )),
    ( "&Euml;",Character(UnicodeScalar(203) )),
    ( "&Igrave;",Character(UnicodeScalar(204) )),
    ( "&Iacute;",Character(UnicodeScalar(205) )),
    ( "&Icirc;",Character(UnicodeScalar(206) )),
    ( "&Iuml;",Character(UnicodeScalar(207) )),
    ( "&ETH;",Character(UnicodeScalar(208) )),
    ( "&Ntilde;",Character(UnicodeScalar(209) )),
    ( "&Ograve;",Character(UnicodeScalar(210) )),
    ( "&Oacute;",Character(UnicodeScalar(211) )),
    ( "&Ocirc;",Character(UnicodeScalar(212) )),
    ( "&Otilde;",Character(UnicodeScalar(213) )),
    ( "&Ouml;",Character(UnicodeScalar(214) )),
    ( "&times;",Character(UnicodeScalar(215) )),
    ( "&Oslash;",Character(UnicodeScalar(216) )),
    ( "&Ugrave;",Character(UnicodeScalar(217) )),
    ( "&Uacute;",Character(UnicodeScalar(218) )),
    ( "&Ucirc;",Character(UnicodeScalar(219) )),
    ( "&Uuml;",Character(UnicodeScalar(220) )),
    ( "&Yacute;",Character(UnicodeScalar(221) )),
    ( "&THORN;",Character(UnicodeScalar(222) )),
    ( "&szlig;",Character(UnicodeScalar(223) )),
    ( "&agrave;",Character(UnicodeScalar(224) )),
    ( "&aacute;",Character(UnicodeScalar(225) )),
    ( "&acirc;",Character(UnicodeScalar(226) )),
    ( "&atilde;",Character(UnicodeScalar(227) )),
    ( "&auml;",Character(UnicodeScalar(228) )),
    ( "&aring;",Character(UnicodeScalar(229) )),
    ( "&aelig;",Character(UnicodeScalar(230) )),
    ( "&ccedil;",Character(UnicodeScalar(231) )),
    ( "&egrave;",Character(UnicodeScalar(232) )),
    ( "&eacute;",Character(UnicodeScalar(233) )),
    ( "&ecirc;",Character(UnicodeScalar(234) )),
    ( "&euml;",Character(UnicodeScalar(235) )),
    ( "&igrave;",Character(UnicodeScalar(236) )),
    ( "&iacute;",Character(UnicodeScalar(237) )),
    ( "&icirc;",Character(UnicodeScalar(238) )),
    ( "&iuml;",Character(UnicodeScalar(239) )),
    ( "&eth;",Character(UnicodeScalar(240) )),
    ( "&ntilde;",Character(UnicodeScalar(241) )),
    ( "&ograve;",Character(UnicodeScalar(242) )),
    ( "&oacute;",Character(UnicodeScalar(243) )),
    ( "&ocirc;",Character(UnicodeScalar(244) )),
    ( "&otilde;",Character(UnicodeScalar(245) )),
    ( "&ouml;",Character(UnicodeScalar(246) )),
    ( "&divide;",Character(UnicodeScalar(247) )),
    ( "&oslash;",Character(UnicodeScalar(248) )),
    ( "&ugrave;",Character(UnicodeScalar(249) )),
    ( "&uacute;",Character(UnicodeScalar(250) )),
    ( "&ucirc;",Character(UnicodeScalar(251) )),
    ( "&uuml;",Character(UnicodeScalar(252) )),
    ( "&yacute;",Character(UnicodeScalar(253) )),
    ( "&thorn;",Character(UnicodeScalar(254) )),
    ( "&yuml;",Character(UnicodeScalar(255) )),
    
    // A.2.2. Special characters cont'd
    ( "&OElig;",Character(UnicodeScalar(UInt32(338))! )),
    ( "&oelig;",Character(UnicodeScalar(UInt32(339))! )),
    ( "&Scaron;",Character(UnicodeScalar(UInt32(352))! )),
    ( "&scaron;",Character(UnicodeScalar(UInt32(353))! )),
    ( "&Yuml;",Character(UnicodeScalar(UInt32(376))! )),
    
    // A.2.3. Symbols
    ( "&fnof;",Character(UnicodeScalar(UInt32(402))! )),
    
    // A.2.2. Special characters cont'd
    ( "&circ;",Character(UnicodeScalar(UInt32(710))! )),
    ( "&tilde;",Character(UnicodeScalar(UInt32(732))! )),
    
    // A.2.3. Symbols cont'd
    ( "&Alpha;",Character(UnicodeScalar(UInt32(913))! )),
    ( "&Beta;",Character(UnicodeScalar(UInt32(914))! )),
    ( "&Gamma;",Character(UnicodeScalar(UInt32(915))! )),
    ( "&Delta;",Character(UnicodeScalar(UInt32(916))! )),
    ( "&Epsilon;",Character(UnicodeScalar(UInt32(917))! )),
    ( "&Zeta;",Character(UnicodeScalar(UInt32(918))! )),
    ( "&Eta;",Character(UnicodeScalar(UInt32(919))! )),
    ( "&Theta;",Character(UnicodeScalar(UInt32(920))! )),
    ( "&Iota;",Character(UnicodeScalar(UInt32(921))! )),
    ( "&Kappa;",Character(UnicodeScalar(UInt32(922))! )),
    ( "&Lambda;",Character(UnicodeScalar(UInt32(923))! )),
    ( "&Mu;",Character(UnicodeScalar(UInt32(924))! )),
    ( "&Nu;",Character(UnicodeScalar(UInt32(925))! )),
    ( "&Xi;",Character(UnicodeScalar(UInt32(926))! )),
    ( "&Omicron;",Character(UnicodeScalar(UInt32(927))! )),
    ( "&Pi;",Character(UnicodeScalar(UInt32(928))! )),
    ( "&Rho;",Character(UnicodeScalar(UInt32(929))! )),
    ( "&Sigma;",Character(UnicodeScalar(UInt32(931))! )),
    ( "&Tau;",Character(UnicodeScalar(UInt32(932))! )),
    ( "&Upsilon;",Character(UnicodeScalar(UInt32(933))! )),
    ( "&Phi;",Character(UnicodeScalar(UInt32(934))! )),
    ( "&Chi;",Character(UnicodeScalar(UInt32(935))! )),
    ( "&Psi;",Character(UnicodeScalar(UInt32(936))! )),
    ( "&Omega;",Character(UnicodeScalar(UInt32(937))! )),
    ( "&alpha;",Character(UnicodeScalar(UInt32(945))! )),
    ( "&beta;",Character(UnicodeScalar(UInt32(946))! )),
    ( "&gamma;",Character(UnicodeScalar(UInt32(947))! )),
    ( "&delta;",Character(UnicodeScalar(UInt32(948))! )),
    ( "&epsilon;",Character(UnicodeScalar(UInt32(949))! )),
    ( "&zeta;",Character(UnicodeScalar(UInt32(950))! )),
    ( "&eta;",Character(UnicodeScalar(UInt32(951))! )),
    ( "&theta;",Character(UnicodeScalar(UInt32(952))! )),
    ( "&iota;",Character(UnicodeScalar(UInt32(953))! )),
    ( "&kappa;",Character(UnicodeScalar(UInt32(954))! )),
    ( "&lambda;",Character(UnicodeScalar(UInt32(955))! )),
    ( "&mu;",Character(UnicodeScalar(UInt32(956))! )),
    ( "&nu;",Character(UnicodeScalar(UInt32(957))! )),
    ( "&xi;",Character(UnicodeScalar(UInt32(958))! )),
    ( "&omicron;",Character(UnicodeScalar(UInt32(959))! )),
    ( "&pi;",Character(UnicodeScalar(UInt32(960))! )),
    ( "&rho;",Character(UnicodeScalar(UInt32(961))! )),
    ( "&sigmaf;",Character(UnicodeScalar(UInt32(962))! )),
    ( "&sigma;",Character(UnicodeScalar(UInt32(963))! )),
    ( "&tau;",Character(UnicodeScalar(UInt32(964))! )),
    ( "&upsilon;",Character(UnicodeScalar(UInt32(965))! )),
    ( "&phi;",Character(UnicodeScalar(UInt32(966))! )),
    ( "&chi;",Character(UnicodeScalar(UInt32(967))! )),
    ( "&psi;",Character(UnicodeScalar(UInt32(968))! )),
    ( "&omega;",Character(UnicodeScalar(UInt32(969))! )),
    ( "&thetasym;",Character(UnicodeScalar(UInt32(977))! )),
    ( "&upsih;",Character(UnicodeScalar(UInt32(978))! )),
    ( "&piv;",Character(UnicodeScalar(UInt32(982))! )),
    
    // A.2.2. Special characters cont'd
    ( "&ensp;",Character(UnicodeScalar(UInt32(8194))! )),
    ( "&emsp;",Character(UnicodeScalar(UInt32(8195))! )),
    ( "&thinsp;",Character(UnicodeScalar(UInt32(8201))! )),
    ( "&zwnj;",Character(UnicodeScalar(UInt32(8204))! )),
    ( "&zwj;",Character(UnicodeScalar(UInt32(8205))! )),
    ( "&lrm;",Character(UnicodeScalar(UInt32(8206))! )),
    ( "&rlm;",Character(UnicodeScalar(UInt32(8207))! )),
    ( "&ndash;",Character(UnicodeScalar(UInt32(8211))! )),
    ( "&mdash;",Character(UnicodeScalar(UInt32(8212))! )),
    ( "&lsquo;",Character(UnicodeScalar(UInt32(8216))! )),
    ( "&rsquo;",Character(UnicodeScalar(UInt32(8217))! )),
    ( "&sbquo;",Character(UnicodeScalar(UInt32(8218))! )),
    ( "&ldquo;",Character(UnicodeScalar(UInt32(8220))! )),
    ( "&rdquo;",Character(UnicodeScalar(UInt32(8221))! )),
    ( "&bdquo;",Character(UnicodeScalar(UInt32(8222))! )),
    ( "&dagger;",Character(UnicodeScalar(UInt32(8224))! )),
    ( "&Dagger;",Character(UnicodeScalar(UInt32(8225))! )),
    // A.2.3. Symbols cont'd
    ( "&bull;",Character(UnicodeScalar(UInt32(8226))! )),
    ( "&hellip;",Character(UnicodeScalar(UInt32(8230))! )),
    
    // A.2.2. Special characters cont'd
    ( "&permil;",Character(UnicodeScalar(UInt32(8240))! )),
    
    // A.2.3. Symbols cont'd
    ( "&prime;",Character(UnicodeScalar(UInt32(8242))! )),
    ( "&Prime;",Character(UnicodeScalar(UInt32(8243))! )),
    
    // A.2.2. Special characters cont'd
    ( "&lsaquo;",Character(UnicodeScalar(UInt32(8249))! )),
    ( "&rsaquo;",Character(UnicodeScalar(UInt32(8250))! )),
    
    // A.2.3. Symbols cont'd
    ( "&oline;",Character(UnicodeScalar(UInt32(8254))! )),
    ( "&frasl;",Character(UnicodeScalar(UInt32(8260))! )),
    
    // A.2.2. Special characters cont'd
    ( "&euro;",Character(UnicodeScalar(UInt32(8364))! )),
    
    // A.2.3. Symbols cont'd
    ( "&image;",Character(UnicodeScalar(UInt32(8465))! )),
    ( "&weierp;",Character(UnicodeScalar(UInt32(8472))! )),
    ( "&real;",Character(UnicodeScalar(UInt32(8476))! )),
    ( "&trade;",Character(UnicodeScalar(UInt32(8482))! )),
    ( "&alefsym;",Character(UnicodeScalar(UInt32(8501))! )),
    ( "&larr;",Character(UnicodeScalar(UInt32(8592))! )),
    ( "&uarr;",Character(UnicodeScalar(UInt32(8593))! )),
    ( "&rarr;",Character(UnicodeScalar(UInt32(8594))! )),
    ( "&darr;",Character(UnicodeScalar(UInt32(8595))! )),
    ( "&harr;",Character(UnicodeScalar(UInt32(8596))! )),
    ( "&crarr;",Character(UnicodeScalar(UInt32(8629))! )),
    ( "&lArr;",Character(UnicodeScalar(UInt32(8656))! )),
    ( "&uArr;",Character(UnicodeScalar(UInt32(8657))! )),
    ( "&rArr;",Character(UnicodeScalar(UInt32(8658))! )),
    ( "&dArr;",Character(UnicodeScalar(UInt32(8659))! )),
    ( "&hArr;",Character(UnicodeScalar(UInt32(8660))! )),
    ( "&forall;",Character(UnicodeScalar(UInt32(8704))! )),
    ( "&part;",Character(UnicodeScalar(UInt32(8706))! )),
    ( "&exist;",Character(UnicodeScalar(UInt32(8707))! )),
    ( "&empty;",Character(UnicodeScalar(UInt32(8709))! )),
    ( "&nabla;",Character(UnicodeScalar(UInt32(8711))! )),
    ( "&isin;",Character(UnicodeScalar(UInt32(8712))! )),
    ( "&notin;",Character(UnicodeScalar(UInt32(8713))! )),
    ( "&ni;",Character(UnicodeScalar(UInt32(8715))! )),
    ( "&prod;",Character(UnicodeScalar(UInt32(8719))! )),
    ( "&sum;",Character(UnicodeScalar(UInt32(8721))! )),
    ( "&minus;",Character(UnicodeScalar(UInt32(8722))! )),
    ( "&lowast;",Character(UnicodeScalar(UInt32(8727))! )),
    ( "&radic;",Character(UnicodeScalar(UInt32(8730))! )),
    ( "&prop;",Character(UnicodeScalar(UInt32(8733))! )),
    ( "&infin;",Character(UnicodeScalar(UInt32(8734))! )),
    ( "&ang;",Character(UnicodeScalar(UInt32(8736))! )),
    ( "&and;",Character(UnicodeScalar(UInt32(8743))! )),
    ( "&or;",Character(UnicodeScalar(UInt32(8744))! )),
    ( "&cap;",Character(UnicodeScalar(UInt32(8745))! )),
    ( "&cup;",Character(UnicodeScalar(UInt32(8746))! )),
    ( "&int;",Character(UnicodeScalar(UInt32(8747))! )),
    ( "&there4;",Character(UnicodeScalar(UInt32(8756))! )),
    ( "&sim;",Character(UnicodeScalar(UInt32(8764))! )),
    ( "&cong;",Character(UnicodeScalar(UInt32(8773))! )),
    ( "&asymp;",Character(UnicodeScalar(UInt32(8776))! )),
    ( "&ne;",Character(UnicodeScalar(UInt32(8800))! )),
    ( "&equiv;",Character(UnicodeScalar(UInt32(8801))! )),
    ( "&le;",Character(UnicodeScalar(UInt32(8804))! )),
    ( "&ge;",Character(UnicodeScalar(UInt32(8805))! )),
    ( "&sub;",Character(UnicodeScalar(UInt32(8834))! )),
    ( "&sup;",Character(UnicodeScalar(UInt32(8835))! )),
    ( "&nsub;",Character(UnicodeScalar(UInt32(8836))! )),
    ( "&sube;",Character(UnicodeScalar(UInt32(8838))! )),
    ( "&supe;",Character(UnicodeScalar(UInt32(8839))! )),
    ( "&oplus;",Character(UnicodeScalar(UInt32(8853))! )),
    ( "&otimes;",Character(UnicodeScalar(UInt32(8855))! )),
    ( "&perp;",Character(UnicodeScalar(UInt32(8869))! )),
    ( "&sdot;",Character(UnicodeScalar(UInt32(8901))! )),
    ( "&lceil;",Character(UnicodeScalar(UInt32(8968))! )),
    ( "&rceil;",Character(UnicodeScalar(UInt32(8969))! )),
    ( "&lfloor;",Character(UnicodeScalar(UInt32(8970))! )),
    ( "&rfloor;",Character(UnicodeScalar(UInt32(8971))! )),
    ( "&lang;",Character(UnicodeScalar(UInt32(9001))! )),
    ( "&rang;",Character(UnicodeScalar(UInt32(9002))! )),
    ( "&loz;",Character(UnicodeScalar(UInt32(9674))! )),
    ( "&spades;",Character(UnicodeScalar(UInt32(9824))! )),
    ( "&clubs;",Character(UnicodeScalar(UInt32(9827))! )),
    ( "&hearts;",Character(UnicodeScalar(UInt32(9829))! )),
    ( "&diams;",Character(UnicodeScalar(UInt32(9830))! ))
]

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// This is table A.2.2 Special Characters
private let unicodeEscapeMap: [(String, Character)] = [
    // C0 Controls and Basic Latin
    ( "&quot;",Character(UnicodeScalar(UInt32(34))! )),
    ( "&amp;",Character(UnicodeScalar(UInt32(38))! )),
    ( "&apos;",Character(UnicodeScalar(UInt32(39))! )),
    ( "&lt;",Character(UnicodeScalar(UInt32(60))! )),
    ( "&gt;",Character(UnicodeScalar(UInt32(62))! )),
    
    // Latin Extended-A
    ( "&OElig;",Character(UnicodeScalar(UInt32(338))! )),
    ( "&oelig;",Character(UnicodeScalar(UInt32(339))! )),
    ( "&Scaron;",Character(UnicodeScalar(UInt32(352))! )),
    ( "&scaron;",Character(UnicodeScalar(UInt32(353))! )),
    ( "&Yuml;",Character(UnicodeScalar(UInt32(376))! )),
    
    // Spacing Modifier Letters
    ( "&circ;",Character(UnicodeScalar(UInt32(710))! )),
    ( "&tilde;",Character(UnicodeScalar(UInt32(732))! )),
    
    // General Punctuation
    ( "&ensp;",Character(UnicodeScalar(UInt32(8194))! )),
    ( "&emsp;",Character(UnicodeScalar(UInt32(8195))! )),
    ( "&thinsp;",Character(UnicodeScalar(UInt32(8201))! )),
    ( "&zwnj;",Character(UnicodeScalar(UInt32(8204))! )),
    ( "&zwj;",Character(UnicodeScalar(UInt32(8205))! )),
    ( "&lrm;",Character(UnicodeScalar(UInt32(8206))! )),
    ( "&rlm;",Character(UnicodeScalar(UInt32(8207))! )),
    ( "&ndash;",Character(UnicodeScalar(UInt32(8211))! )),
    ( "&mdash;",Character(UnicodeScalar(UInt32(8212))! )),
    ( "&lsquo;",Character(UnicodeScalar(UInt32(8216))! )),
    ( "&rsquo;",Character(UnicodeScalar(UInt32(8217))! )),
    ( "&sbquo;",Character(UnicodeScalar(UInt32(8218))! )),
    ( "&ldquo;",Character(UnicodeScalar(UInt32(8220))! )),
    ( "&rdquo;",Character(UnicodeScalar(UInt32(8221))! )),
    ( "&bdquo;",Character(UnicodeScalar(UInt32(8222))! )),
    ( "&dagger;",Character(UnicodeScalar(UInt32(8224))! )),
    ( "&Dagger;",Character(UnicodeScalar(UInt32(8225))! )),
    ( "&permil;",Character(UnicodeScalar(UInt32(8240))! )),
    ( "&lsaquo;",Character(UnicodeScalar(UInt32(8249))! )),
    ( "&rsaquo;",Character(UnicodeScalar(UInt32(8250))! )),
    ( "&euro;",Character(UnicodeScalar(UInt32(8364))! )),
]


private let completeMap = asciiEscapeMap + unicodeEscapeMap

