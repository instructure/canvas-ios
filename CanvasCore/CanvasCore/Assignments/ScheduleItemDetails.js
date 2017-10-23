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


function hideAllForms() {
    var forms = document.forms;
    for (var i=0; i<forms.length; ++i) {
        var form = forms[i];
        form.style.display = 'none';
    }   
}

function showFormWithId(formId) {
    var myblock = document.getElementById(formId);
    myblock.style.display = 'inline';
}

function setGradeBlockHTML(content, showOnNewline) {
    var submissionInfoBlock = document.getElementById('submission-info');
    var gradeBlock = document.getElementById('grade');
    if (showOnNewline) {
        gradeBlock.style.display = 'block';
    }
    else {
        gradeBlock.style.display = 'inline';
    }
    gradeBlock.innerHTML = content;
}