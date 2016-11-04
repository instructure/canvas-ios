
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
        var str = self.stringByReplacingOccurrencesOfString("<br[^>]*>", withString: "\n", options: [.RegularExpressionSearch, .CaseInsensitiveSearch], range: nil)
        str = str.stringByReplacingOccurrencesOfString("</*p[^>]*>", withString: "\n", options: [.RegularExpressionSearch, .CaseInsensitiveSearch], range: nil)
        str = str.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        for (escaped, char) in map {
            str = str.stringByReplacingOccurrencesOfString(escaped, withString: String([char]), options: .CaseInsensitiveSearch, range: nil)
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
    ( "&OElig;",Character(UnicodeScalar(338) )),
    ( "&oelig;",Character(UnicodeScalar(339) )),
    ( "&Scaron;",Character(UnicodeScalar(352) )),
    ( "&scaron;",Character(UnicodeScalar(353) )),
    ( "&Yuml;",Character(UnicodeScalar(376) )),
    
    // A.2.3. Symbols
    ( "&fnof;",Character(UnicodeScalar(402) )),
    
    // A.2.2. Special characters cont'd
    ( "&circ;",Character(UnicodeScalar(710) )),
    ( "&tilde;",Character(UnicodeScalar(732) )),
    
    // A.2.3. Symbols cont'd
    ( "&Alpha;",Character(UnicodeScalar(913) )),
    ( "&Beta;",Character(UnicodeScalar(914) )),
    ( "&Gamma;",Character(UnicodeScalar(915) )),
    ( "&Delta;",Character(UnicodeScalar(916) )),
    ( "&Epsilon;",Character(UnicodeScalar(917) )),
    ( "&Zeta;",Character(UnicodeScalar(918) )),
    ( "&Eta;",Character(UnicodeScalar(919) )),
    ( "&Theta;",Character(UnicodeScalar(920) )),
    ( "&Iota;",Character(UnicodeScalar(921) )),
    ( "&Kappa;",Character(UnicodeScalar(922) )),
    ( "&Lambda;",Character(UnicodeScalar(923) )),
    ( "&Mu;",Character(UnicodeScalar(924) )),
    ( "&Nu;",Character(UnicodeScalar(925) )),
    ( "&Xi;",Character(UnicodeScalar(926) )),
    ( "&Omicron;",Character(UnicodeScalar(927) )),
    ( "&Pi;",Character(UnicodeScalar(928) )),
    ( "&Rho;",Character(UnicodeScalar(929) )),
    ( "&Sigma;",Character(UnicodeScalar(931) )),
    ( "&Tau;",Character(UnicodeScalar(932) )),
    ( "&Upsilon;",Character(UnicodeScalar(933) )),
    ( "&Phi;",Character(UnicodeScalar(934) )),
    ( "&Chi;",Character(UnicodeScalar(935) )),
    ( "&Psi;",Character(UnicodeScalar(936) )),
    ( "&Omega;",Character(UnicodeScalar(937) )),
    ( "&alpha;",Character(UnicodeScalar(945) )),
    ( "&beta;",Character(UnicodeScalar(946) )),
    ( "&gamma;",Character(UnicodeScalar(947) )),
    ( "&delta;",Character(UnicodeScalar(948) )),
    ( "&epsilon;",Character(UnicodeScalar(949) )),
    ( "&zeta;",Character(UnicodeScalar(950) )),
    ( "&eta;",Character(UnicodeScalar(951) )),
    ( "&theta;",Character(UnicodeScalar(952) )),
    ( "&iota;",Character(UnicodeScalar(953) )),
    ( "&kappa;",Character(UnicodeScalar(954) )),
    ( "&lambda;",Character(UnicodeScalar(955) )),
    ( "&mu;",Character(UnicodeScalar(956) )),
    ( "&nu;",Character(UnicodeScalar(957) )),
    ( "&xi;",Character(UnicodeScalar(958) )),
    ( "&omicron;",Character(UnicodeScalar(959) )),
    ( "&pi;",Character(UnicodeScalar(960) )),
    ( "&rho;",Character(UnicodeScalar(961) )),
    ( "&sigmaf;",Character(UnicodeScalar(962) )),
    ( "&sigma;",Character(UnicodeScalar(963) )),
    ( "&tau;",Character(UnicodeScalar(964) )),
    ( "&upsilon;",Character(UnicodeScalar(965) )),
    ( "&phi;",Character(UnicodeScalar(966) )),
    ( "&chi;",Character(UnicodeScalar(967) )),
    ( "&psi;",Character(UnicodeScalar(968) )),
    ( "&omega;",Character(UnicodeScalar(969) )),
    ( "&thetasym;",Character(UnicodeScalar(977) )),
    ( "&upsih;",Character(UnicodeScalar(978) )),
    ( "&piv;",Character(UnicodeScalar(982) )),
    
    // A.2.2. Special characters cont'd
    ( "&ensp;",Character(UnicodeScalar(8194) )),
    ( "&emsp;",Character(UnicodeScalar(8195) )),
    ( "&thinsp;",Character(UnicodeScalar(8201) )),
    ( "&zwnj;",Character(UnicodeScalar(8204) )),
    ( "&zwj;",Character(UnicodeScalar(8205) )),
    ( "&lrm;",Character(UnicodeScalar(8206) )),
    ( "&rlm;",Character(UnicodeScalar(8207) )),
    ( "&ndash;",Character(UnicodeScalar(8211) )),
    ( "&mdash;",Character(UnicodeScalar(8212) )),
    ( "&lsquo;",Character(UnicodeScalar(8216) )),
    ( "&rsquo;",Character(UnicodeScalar(8217) )),
    ( "&sbquo;",Character(UnicodeScalar(8218) )),
    ( "&ldquo;",Character(UnicodeScalar(8220) )),
    ( "&rdquo;",Character(UnicodeScalar(8221) )),
    ( "&bdquo;",Character(UnicodeScalar(8222) )),
    ( "&dagger;",Character(UnicodeScalar(8224) )),
    ( "&Dagger;",Character(UnicodeScalar(8225) )),
    // A.2.3. Symbols cont'd
    ( "&bull;",Character(UnicodeScalar(8226) )),
    ( "&hellip;",Character(UnicodeScalar(8230) )),
    
    // A.2.2. Special characters cont'd
    ( "&permil;",Character(UnicodeScalar(8240) )),
    
    // A.2.3. Symbols cont'd
    ( "&prime;",Character(UnicodeScalar(8242) )),
    ( "&Prime;",Character(UnicodeScalar(8243) )),
    
    // A.2.2. Special characters cont'd
    ( "&lsaquo;",Character(UnicodeScalar(8249) )),
    ( "&rsaquo;",Character(UnicodeScalar(8250) )),
    
    // A.2.3. Symbols cont'd
    ( "&oline;",Character(UnicodeScalar(8254) )),
    ( "&frasl;",Character(UnicodeScalar(8260) )),
    
    // A.2.2. Special characters cont'd
    ( "&euro;",Character(UnicodeScalar(8364) )),
    
    // A.2.3. Symbols cont'd
    ( "&image;",Character(UnicodeScalar(8465) )),
    ( "&weierp;",Character(UnicodeScalar(8472) )),
    ( "&real;",Character(UnicodeScalar(8476) )),
    ( "&trade;",Character(UnicodeScalar(8482) )),
    ( "&alefsym;",Character(UnicodeScalar(8501) )),
    ( "&larr;",Character(UnicodeScalar(8592) )),
    ( "&uarr;",Character(UnicodeScalar(8593) )),
    ( "&rarr;",Character(UnicodeScalar(8594) )),
    ( "&darr;",Character(UnicodeScalar(8595) )),
    ( "&harr;",Character(UnicodeScalar(8596) )),
    ( "&crarr;",Character(UnicodeScalar(8629) )),
    ( "&lArr;",Character(UnicodeScalar(8656) )),
    ( "&uArr;",Character(UnicodeScalar(8657) )),
    ( "&rArr;",Character(UnicodeScalar(8658) )),
    ( "&dArr;",Character(UnicodeScalar(8659) )),
    ( "&hArr;",Character(UnicodeScalar(8660) )),
    ( "&forall;",Character(UnicodeScalar(8704) )),
    ( "&part;",Character(UnicodeScalar(8706) )),
    ( "&exist;",Character(UnicodeScalar(8707) )),
    ( "&empty;",Character(UnicodeScalar(8709) )),
    ( "&nabla;",Character(UnicodeScalar(8711) )),
    ( "&isin;",Character(UnicodeScalar(8712) )),
    ( "&notin;",Character(UnicodeScalar(8713) )),
    ( "&ni;",Character(UnicodeScalar(8715) )),
    ( "&prod;",Character(UnicodeScalar(8719) )),
    ( "&sum;",Character(UnicodeScalar(8721) )),
    ( "&minus;",Character(UnicodeScalar(8722) )),
    ( "&lowast;",Character(UnicodeScalar(8727) )),
    ( "&radic;",Character(UnicodeScalar(8730) )),
    ( "&prop;",Character(UnicodeScalar(8733) )),
    ( "&infin;",Character(UnicodeScalar(8734) )),
    ( "&ang;",Character(UnicodeScalar(8736) )),
    ( "&and;",Character(UnicodeScalar(8743) )),
    ( "&or;",Character(UnicodeScalar(8744) )),
    ( "&cap;",Character(UnicodeScalar(8745) )),
    ( "&cup;",Character(UnicodeScalar(8746) )),
    ( "&int;",Character(UnicodeScalar(8747) )),
    ( "&there4;",Character(UnicodeScalar(8756) )),
    ( "&sim;",Character(UnicodeScalar(8764) )),
    ( "&cong;",Character(UnicodeScalar(8773) )),
    ( "&asymp;",Character(UnicodeScalar(8776) )),
    ( "&ne;",Character(UnicodeScalar(8800) )),
    ( "&equiv;",Character(UnicodeScalar(8801) )),
    ( "&le;",Character(UnicodeScalar(8804) )),
    ( "&ge;",Character(UnicodeScalar(8805) )),
    ( "&sub;",Character(UnicodeScalar(8834) )),
    ( "&sup;",Character(UnicodeScalar(8835) )),
    ( "&nsub;",Character(UnicodeScalar(8836) )),
    ( "&sube;",Character(UnicodeScalar(8838) )),
    ( "&supe;",Character(UnicodeScalar(8839) )),
    ( "&oplus;",Character(UnicodeScalar(8853) )),
    ( "&otimes;",Character(UnicodeScalar(8855) )),
    ( "&perp;",Character(UnicodeScalar(8869) )),
    ( "&sdot;",Character(UnicodeScalar(8901) )),
    ( "&lceil;",Character(UnicodeScalar(8968) )),
    ( "&rceil;",Character(UnicodeScalar(8969) )),
    ( "&lfloor;",Character(UnicodeScalar(8970) )),
    ( "&rfloor;",Character(UnicodeScalar(8971) )),
    ( "&lang;",Character(UnicodeScalar(9001) )),
    ( "&rang;",Character(UnicodeScalar(9002) )),
    ( "&loz;",Character(UnicodeScalar(9674) )),
    ( "&spades;",Character(UnicodeScalar(9824) )),
    ( "&clubs;",Character(UnicodeScalar(9827) )),
    ( "&hearts;",Character(UnicodeScalar(9829) )),
    ( "&diams;",Character(UnicodeScalar(9830) ))
]

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// This is table A.2.2 Special Characters
private let unicodeEscapeMap: [(String, Character)] = [
    // C0 Controls and Basic Latin
    ( "&quot;",Character(UnicodeScalar(34) )),
    ( "&amp;",Character(UnicodeScalar(38) )),
    ( "&apos;",Character(UnicodeScalar(39) )),
    ( "&lt;",Character(UnicodeScalar(60) )),
    ( "&gt;",Character(UnicodeScalar(62) )),
    
    // Latin Extended-A
    ( "&OElig;",Character(UnicodeScalar(338) )),
    ( "&oelig;",Character(UnicodeScalar(339) )),
    ( "&Scaron;",Character(UnicodeScalar(352) )),
    ( "&scaron;",Character(UnicodeScalar(353) )),
    ( "&Yuml;",Character(UnicodeScalar(376) )),
    
    // Spacing Modifier Letters
    ( "&circ;",Character(UnicodeScalar(710) )),
    ( "&tilde;",Character(UnicodeScalar(732) )),
    
    // General Punctuation
    ( "&ensp;",Character(UnicodeScalar(8194) )),
    ( "&emsp;",Character(UnicodeScalar(8195) )),
    ( "&thinsp;",Character(UnicodeScalar(8201) )),
    ( "&zwnj;",Character(UnicodeScalar(8204) )),
    ( "&zwj;",Character(UnicodeScalar(8205) )),
    ( "&lrm;",Character(UnicodeScalar(8206) )),
    ( "&rlm;",Character(UnicodeScalar(8207) )),
    ( "&ndash;",Character(UnicodeScalar(8211) )),
    ( "&mdash;",Character(UnicodeScalar(8212) )),
    ( "&lsquo;",Character(UnicodeScalar(8216) )),
    ( "&rsquo;",Character(UnicodeScalar(8217) )),
    ( "&sbquo;",Character(UnicodeScalar(8218) )),
    ( "&ldquo;",Character(UnicodeScalar(8220) )),
    ( "&rdquo;",Character(UnicodeScalar(8221) )),
    ( "&bdquo;",Character(UnicodeScalar(8222) )),
    ( "&dagger;",Character(UnicodeScalar(8224) )),
    ( "&Dagger;",Character(UnicodeScalar(8225) )),
    ( "&permil;",Character(UnicodeScalar(8240) )),
    ( "&lsaquo;",Character(UnicodeScalar(8249) )),
    ( "&rsaquo;",Character(UnicodeScalar(8250) )),
    ( "&euro;",Character(UnicodeScalar(8364) )),
]


private let map = asciiEscapeMap + unicodeEscapeMap
