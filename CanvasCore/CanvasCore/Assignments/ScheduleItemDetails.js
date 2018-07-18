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