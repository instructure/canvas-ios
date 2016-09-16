
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