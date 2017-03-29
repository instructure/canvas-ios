/*
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Note: This file contains code based on Espresso Web v2.2.2

// package android.support.test.espresso.web.action;
// GENERATED CODE DO NOT EDIT
// ~/Library/Android/sdk/extras/android/m2repository/com/android/support/test/espresso/espresso-web/
// espresso-web-2.2.2
public struct EvaluationAtom {
/* field: EXECUTE_SCRIPT_ANDROID license:

 Copyright 2014 Software Freedom Conservancy

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
  public static let EXECUTE_SCRIPT_ANDROID:String =
    "function(){return(function(){function g(a){var b=typeof a;if(\"obje" +
    "ct\"==b)if(a){if(a instanceof Array)return\"array\";if(a instanceof O" +
    "bject)return b;var c=Object.prototype.toString.call(a);if(\"[object" +
    " Window]\"==c)return\"object\";if(\"[object Array]\"==c||\"number\"==type" +
    "of a.length&&\"undefined\"!=typeof a.splice&&\"undefined\"!=typeof a.p" +
    "ropertyIsEnumerable&&!a.propertyIsEnumerable(\"splice\"))return\"arra" +
    "y\";if(\"[object Function]\"==c||\"undefined\"!=typeof a.call&&\"undefin" +
    "ed\"!=typeof a.propertyIsEnumerable&&!a.propertyIsEnumerable(\"call\"" +
    "))return\"function\"}else return\"null\";\nelse if(\"function\"==b&&\"unde" +
    "fined\"==typeof a.call)return\"object\";return b}function h(a){var b=" +
    "g(a);return\"array\"==b||\"object\"==b&&\"number\"==typeof a.length}func" +
    "tion l(a){var b=typeof a;return\"object\"==b&&null!=a||\"function\"==b" +
    "}var q=Date.now||function(){return+new Date};var r=String.prototyp" +
    "e.trim?function(a){return a.trim()}:function(a){return a.replace(/" +
    "^[\\s\\xa0]+|[\\s\\xa0]+$/g,\"\")};function t(a,b){return a<b?-1:a>b?1:0" +
    "};function u(a,b){for(var c=a.length,d=Array(c),f=\"string\"==typeof" +
    " a?a.split(\"\"):a,e=0;e<c;e++)e in f&&(d[e]=b.call(void 0,f[e],e,a)" +
    ");return d};function v(a,b){var c={},d;for(d in a)b.call(void 0,a[" +
    "d],d,a)&&(c[d]=a[d]);return c}function w(a,b){var c={},d;for(d in " +
    "a)c[d]=b.call(void 0,a[d],d,a);return c}function x(a,b){return nul" +
    "l!==a&&b in a}function y(a,b){for(var c in a)if(b.call(void 0,a[c]" +
    ",c,a))return c};var A;a:{var B=this.navigator;if(B){var C=B.userAg" +
    "ent;if(C){A=C;break a}}A=\"\"};/*xxx_rpl_lic*/\nvar D=window;function" +
    " E(a,b){this.code=a;this.b=F[a]||\"unknown error\";this.message=b||\"" +
    "\";var c=this.b.replace(/((?:^|\\s+)[a-z])/g,function(a){return a.to" +
    "UpperCase().replace(/^[\\s\\xa0]+/g,\"\")}),d=c.length-5;if(0>d||c.ind" +
    "exOf(\"Error\",d)!=d)c+=\"Error\";this.name=c;c=Error(this.message);c." +
    "name=this.name;this.stack=c.stack||\"\"}\n(function(){var a=Error;fun" +
    "ction b(){}b.prototype=a.prototype;E.c=a.prototype;E.prototype=new" +
    " b;E.prototype.constructor=E;E.b=function(b,d,f){for(var e=Array(a" +
    "rguments.length-2),k=2;k<arguments.length;k++)e[k-2]=arguments[k];" +
    "return a.prototype[d].apply(b,e)}})();\nvar F={15:\"element not sele" +
    "ctable\",11:\"element not visible\",31:\"unknown error\",30:\"unknown er" +
    "ror\",24:\"invalid cookie domain\",29:\"invalid element coordinates\",1" +
    "2:\"invalid element state\",32:\"invalid selector\",51:\"invalid select" +
    "or\",52:\"invalid selector\",17:\"javascript error\",405:\"unsupported o" +
    "peration\",34:\"move target out of bounds\",27:\"no such alert\",7:\"no " +
    "such element\",8:\"no such frame\",23:\"no such window\",28:\"script tim" +
    "eout\",33:\"session not created\",10:\"stale element reference\",21:\"ti" +
    "meout\",25:\"unable to set cookie\",\n26:\"unexpected alert open\",13:\"u" +
    "nknown error\",9:\"unknown command\"};E.prototype.toString=function()" +
    "{return this.name+\": \"+this.message};function G(){}\nfunction H(a,b" +
    ",c){if(null==b)c.push(\"null\");else{if(\"object\"==typeof b){if(\"arra" +
    "y\"==g(b)){var d=b;b=d.length;c.push(\"[\");for(var f=\"\",e=0;e<b;e++)" +
    "c.push(f),H(a,d[e],c),f=\",\";c.push(\"]\");return}if(b instanceof Str" +
    "ing||b instanceof Number||b instanceof Boolean)b=b.valueOf();else{" +
    "c.push(\"{\");f=\"\";for(d in b)Object.prototype.hasOwnProperty.call(b" +
    ",d)&&(e=b[d],\"function\"!=typeof e&&(c.push(f),I(d,c),c.push(\":\"),H" +
    "(a,e,c),f=\",\"));c.push(\"}\");return}}switch(typeof b){case \"string\"" +
    ":I(b,c);break;case \"number\":c.push(isFinite(b)&&\n!isNaN(b)?String(" +
    "b):\"null\");break;case \"boolean\":c.push(String(b));break;case \"func" +
    "tion\":c.push(\"null\");break;default:throw Error(\"Unknown type: \"+ty" +
    "peof b);}}}var J={'\"':'\\\\\"',\"\\\\\":\"\\\\\\\\\",\"/\":\"\\\\/\",\"\\b\":\"\\\\b\",\"\\f\":" +
    "\"\\\\f\",\"\\n\":\"\\\\n\",\"\\r\":\"\\\\r\",\"\\t\":\"\\\\t\",\"\\x0B\":\"\\\\u000b\"},K=/\\uffff" +
    "/.test(\"\\uffff\")?/[\\\\\\\"\\x00-\\x1f\\x7f-\\uffff]/g:/[\\\\\\\"\\x00-\\x1f\\x7f" +
    "-\\xff]/g;\nfunction I(a,b){b.push('\"',a.replace(K,function(a){var b" +
    "=J[a];b||(b=\"\\\\u\"+(a.charCodeAt(0)|65536).toString(16).substr(1),J" +
    "[a]=b);return b}),'\"')};function L(a){return(a=a.exec(A))?a[1]:\"\"}" +
    "L(/Android\\s+([0-9.]+)/)||L(/Version\\/([0-9.]+)/);function M(a){va" +
    "r b=0,c=r(String(N)).split(\".\");a=r(String(a)).split(\".\");for(var " +
    "d=Math.max(c.length,a.length),f=0;0==b&&f<d;f++){var e=c[f]||\"\",k=" +
    "a[f]||\"\",z=RegExp(\"(\\\\d*)(\\\\D*)\",\"g\"),m=RegExp(\"(\\\\d*)(\\\\D*)\",\"g\")" +
    ";do{var n=z.exec(e)||[\"\",\"\",\"\"],p=m.exec(k)||[\"\",\"\",\"\"];if(0==n[0]" +
    ".length&&0==p[0].length)break;b=t(0==n[1].length?0:parseInt(n[1],1" +
    "0),0==p[1].length?0:parseInt(p[1],10))||t(0==n[2].length,0==p[2].l" +
    "ength)||t(n[2],p[2])}while(0==b)}}var O=/Android\\s+([0-9\\.]+)/.exe" +
    "c(A),N=O?O[1]:\"0\";M(2.3);\nM(4);function P(a){switch(g(a)){case \"st" +
    "ring\":case \"number\":case \"boolean\":return a;case \"function\":return" +
    " a.toString();case \"array\":return u(a,P);case \"object\":if(x(a,\"nod" +
    "eType\")&&(1==a.nodeType||9==a.nodeType)){var b={};b.ELEMENT=Q(a);r" +
    "eturn b}if(x(a,\"document\"))return b={},b.WINDOW=Q(a),b;if(h(a))ret" +
    "urn u(a,P);a=v(a,function(a,b){return\"number\"==typeof b||\"string\"=" +
    "=typeof b});return w(a,P);default:return null}}\nfunction R(a,b){re" +
    "turn\"array\"==g(a)?u(a,function(a){return R(a,b)}):l(a)?\"function\"=" +
    "=typeof a?a:x(a,\"ELEMENT\")?S(a.ELEMENT,b):x(a,\"WINDOW\")?S(a.WINDOW" +
    ",b):w(a,function(a){return R(a,b)}):a}function T(a){a=a||document;" +
    "var b=a.$wdc_;b||(b=a.$wdc_={},b.a=q());b.a||(b.a=q());return b}fu" +
    "nction Q(a){var b=T(a.ownerDocument),c=y(b,function(b){return b==a" +
    "});c||(c=\":wdc:\"+b.a++,b[c]=a);return c}\nfunction S(a,b){a=decodeU" +
    "RIComponent(a);var c=b||document,d=T(c);if(!x(d,a))throw new E(10," +
    "\"Element does not exist in cache\");var f=d[a];if(x(f,\"setInterval\"" +
    ")){if(f.closed)throw delete d[a],new E(23,\"Window has been closed." +
    "\");return f}for(var e=f;e;){if(e==c.documentElement)return f;e=e.p" +
    "arentNode}delete d[a];throw new E(10,\"Element is no longer attache" +
    "d to the DOM\");};function U(a,b,c,d){d=d||D;var f;try{a:{var e=a;i" +
    "f(\"string\"==typeof e)try{a=new d.Function(e);break a}catch(m){thro" +
    "w m;}a=d==window?e:new d.Function(\"return (\"+e+\").apply(null,argum" +
    "ents);\")}var k=R(b,d.document),z=a.apply(null,k);f={status:0,value" +
    ":P(z)}}catch(m){f={status:x(m,\"code\")?m.code:13,value:{message:m.m" +
    "essage}}}c&&(a=[],H(new G,f,a),f=a.join(\"\"));return f}var V=[\"_\"]," +
    "W=this;V[0]in W||!W.execScript||W.execScript(\"var \"+V[0]);\nfor(var" +
    " X;V.length&&(X=V.shift());){var Y;if(Y=!V.length)Y=void 0!==U;Y?W" +
    "[X]=U:W[X]?W=W[X]:W=W[X]={}};;return this._.apply(null,arguments);" +
    "}).apply({navigator:typeof window!=\"undefined\"?window.navigator:nu" +
    "ll},arguments);}\n"
  public static let EXECUTE_SCRIPT_ANDROID_license:String =
  "\n\n Copyright 2014 Software Freedom Conservancy\n\n Licensed under th" +
  "e Apache License, Version 2.0 (the \"License\");\n you may not use th" +
  "is file except in compliance with the License.\n You may obtain a c" +
  "opy of the License at\n\n      http://www.apache.org/licenses/LICENS" +
  "E-2.0\n\n Unless required by applicable law or agreed to in writing," +
  " software\n distributed under the License is distributed on an \"AS " +
  "IS\" BASIS,\n WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either e" +
  "xpress or implied.\n See the License for the specific language gove" +
  "rning permissions and\n limitations under the License.\n";
  private static func EXECUTE_SCRIPT_ANDROID_original() -> String {
    return EXECUTE_SCRIPT_ANDROID.replacingOccurrences(of: "xxx_rpl_lic", with: EXECUTE_SCRIPT_ANDROID_license);
  }

/* field: GET_ELEMENT_ANDROID license:

 Copyright 2014 Software Freedom Conservancy

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
  public static let GET_ELEMENT_ANDROID:String =
    "function(){return(function(){var f=Date.now||function(){return+new" +
    " Date};var g=String.prototype.trim?function(a){return a.trim()}:fu" +
    "nction(a){return a.replace(/^[\\s\\xa0]+|[\\s\\xa0]+$/g,\"\")};function " +
    "n(a,c){return a<c?-1:a>c?1:0};var p;a:{var q=this.navigator;if(q){" +
    "var r=q.userAgent;if(r){p=r;break a}}p=\"\"};/*xxx_rpl_lic*/\nfunctio" +
    "n t(a,c){this.code=a;this.a=u[a]||\"unknown error\";this.message=c||" +
    "\"\";var d=this.a.replace(/((?:^|\\s+)[a-z])/g,function(a){return a.t" +
    "oUpperCase().replace(/^[\\s\\xa0]+/g,\"\")}),e=d.length-5;if(0>e||d.in" +
    "dexOf(\"Error\",e)!=e)d+=\"Error\";this.name=d;d=Error(this.message);d" +
    ".name=this.name;this.stack=d.stack||\"\"}\n(function(){var a=Error;fu" +
    "nction c(){}c.prototype=a.prototype;t.c=a.prototype;t.prototype=ne" +
    "w c;t.prototype.constructor=t;t.a=function(d,e,b){for(var c=Array(" +
    "arguments.length-2),k=2;k<arguments.length;k++)c[k-2]=arguments[k]" +
    ";return a.prototype[e].apply(d,c)}})();\nvar u={15:\"element not sel" +
    "ectable\",11:\"element not visible\",31:\"unknown error\",30:\"unknown e" +
    "rror\",24:\"invalid cookie domain\",29:\"invalid element coordinates\"," +
    "12:\"invalid element state\",32:\"invalid selector\",51:\"invalid selec" +
    "tor\",52:\"invalid selector\",17:\"javascript error\",405:\"unsupported " +
    "operation\",34:\"move target out of bounds\",27:\"no such alert\",7:\"no" +
    " such element\",8:\"no such frame\",23:\"no such window\",28:\"script ti" +
    "meout\",33:\"session not created\",10:\"stale element reference\",21:\"t" +
    "imeout\",25:\"unable to set cookie\",\n26:\"unexpected alert open\",13:\"" +
    "unknown error\",9:\"unknown command\"};t.prototype.toString=function(" +
    "){return this.name+\": \"+this.message};function v(a){return(a=a.exe" +
    "c(p))?a[1]:\"\"}v(/Android\\s+([0-9.]+)/)||v(/Version\\/([0-9.]+)/);fu" +
    "nction w(a){var c=0,d=g(String(x)).split(\".\");a=g(String(a)).split" +
    "(\".\");for(var e=Math.max(d.length,a.length),b=0;0==c&&b<e;b++){var" +
    " h=d[b]||\"\",k=a[b]||\"\",E=RegExp(\"(\\\\d*)(\\\\D*)\",\"g\"),F=RegExp(\"(\\\\d" +
    "*)(\\\\D*)\",\"g\");do{var l=E.exec(h)||[\"\",\"\",\"\"],m=F.exec(k)||[\"\",\"\"," +
    "\"\"];if(0==l[0].length&&0==m[0].length)break;c=n(0==l[1].length?0:p" +
    "arseInt(l[1],10),0==m[1].length?0:parseInt(m[1],10))||n(0==l[2].le" +
    "ngth,0==m[2].length)||n(l[2],m[2])}while(0==c)}}var y=/Android\\s+(" +
    "[0-9\\.]+)/.exec(p),x=y?y[1]:\"0\";w(2.3);\nw(4);function z(a,c){a=dec" +
    "odeURIComponent(a);var d=c||document,e;e=d||document;var b=e.$wdc_" +
    ";b||(b=e.$wdc_={},b.b=f());b.b||(b.b=f());e=b;if(!(a in e))throw n" +
    "ew t(10,\"Element does not exist in cache\");b=e[a];if(\"setInterval\"" +
    "in b){if(b.closed)throw delete e[a],new t(23,\"Window has been clos" +
    "ed.\");return b}for(var h=b;h;){if(h==d.documentElement)return b;h=" +
    "h.parentNode}delete e[a];throw new t(10,\"Element is no longer atta" +
    "ched to the DOM\");}var A=[\"_\"],B=this;A[0]in B||!B.execScript||B.e" +
    "xecScript(\"var \"+A[0]);\nfor(var C;A.length&&(C=A.shift());){var D;" +
    "if(D=!A.length)D=void 0!==z;D?B[C]=z:B[C]?B=B[C]:B=B[C]={}};;retur" +
    "n this._.apply(null,arguments);}).apply({navigator:typeof window!=" +
    "\"undefined\"?window.navigator:null},arguments);}\n"
  public static let GET_ELEMENT_ANDROID_license:String =
    "\n\n Copyright 2014 Software Freedom Conservancy\n\n Licensed under th" +
    "e Apache License, Version 2.0 (the \"License\");\n you may not use th" +
    "is file except in compliance with the License.\n You may obtain a c" +
    "opy of the License at\n\n      http://www.apache.org/licenses/LICENS" +
    "E-2.0\n\n Unless required by applicable law or agreed to in writing," +
    " software\n distributed under the License is distributed on an \"AS " +
    "IS\" BASIS,\n WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either e" +
    "xpress or implied.\n See the License for the specific language gove" +
    "rning permissions and\n limitations under the License.\n"
  private static func GET_ELEMENT_ANDROID_original() -> String {
  return GET_ELEMENT_ANDROID.replacingOccurrences(of: "xxx_rpl_lic", with: GET_ELEMENT_ANDROID_license);
  }

}
