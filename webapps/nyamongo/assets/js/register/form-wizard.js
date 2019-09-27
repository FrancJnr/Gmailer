var FormWizard = function () {

    var args = {};

    return {
        //main function to initiate the module
        init: function (Args) {
            args = Args;
            if (!jQuery().bootstrapWizard) {
                return;
            }


            function format(state) {
                if (!state.id) return state.text; // optgroup
                return "<img class='flag' src='./assets/img/flags/" + state.id.toLowerCase() + ".png'/>&nbsp;&nbsp;" + state.text;
            }

            $("#country_list").select2({
                placeholder: "Select",
                allowClear: true,
                formatResult: format,
                formatSelection: format,
                escapeMarkup: function (m) {
                    return m;
                }
            });

            var form = $('#submit_form_1');
            var error = $('.alert-danger', form);
            var errorServer = $('.alert-danger-server', form);
            var success = $('.confirm', form);
            var successProgress = $('.progress-step', form);
            var frm = $('#declare_agree');


            form.validate({
                doNotHideMessage: true, //this option enables to show the error/success messages on tab switch.
                errorElement: 'span', //default input error message container
                errorClass: 'help-block help-block-error', // default input error message class
                focusInvalid: false, // do not focus the last invalid input
                //ignore: "input[type='file']",
                //ignore: "[@type=file]",
                rules: {
                    // Section A
                    surname: {
                        required: false
                    },
                    firstname: {
                        required: false
                    },
                    lastname: {
                        required: false
                    },
                    chosen_payment: {
                        required: false
                    },
                    file: {
                        required: false
                    },
                    bank_slip_upload: {
                        required: false
                    },
                    sponsor_slip_upload: {
                        required: false
                    },
                    appointment_slip_upload: {
                        required: false
                    },
                    cv_slip_upload: {
                        required: false
                    },
                    id_slip_upload: {
                        required: false
                    },
                    dob: {
                        required: true
                    },
                    denomination: {
                        required: true
                    },
                    tel_no: {
                        required: false
                    },
                    mobile_no: {
                        required: true
                    },
                    current_address: {
                        required: true
                    },
                    permanent_address: {
                        required: true
                    },
                    email: {
                        required: true,
                        email: true
                    },
                    remail: {
                        required: true,
                        email: true,
                        equalTo: "#submit_form_email"
                    },
                    nationality: {
                        required: true
                    },
                    passport_id_no: {
                        required: true
                    },
                    marital_status: {
                        required: true
                    },
                    religion: {
                        required: true
                    },
                    disability_bool: {
                        required: true
                    },
                    gender: {
                        required: true
                    },
                    //done
                    password: {
                        minlength: 5,
                        required: true
                    },
                    rpassword: {
                        minlength: 5,
                        required: true,
                        equalTo: "#submit_form_password"
                    },
                    //section B
                    degree_1: {
                        required: true
                    },
                    university_1: {
                        required: true
                    },
                    completion_yr_1: {
                        required: true
                    },
                    grades_1: {
                        required: true
                    },
                    school: {
                        required: true
                    },
                    post_grad: {
                        required: false
                    },
                    is_english: {
                        required: true
                    },
                    prof_test: {
                        required: false
                    },
                    test_name: {
                        required: false
                    },
                    accomodation: {
                        required: true
                    },
                    sponsored: {
                        required: true
                    },
                    sponsores: {
                        required: true
                    },
                    campus_site: {
                        required: true
                    },
                    occupation_1: {
                        required: true
                    },
                    employer_1: {
                        required: true
                    },
                    workstation_1: {
                        required: true
                    },
                    duration_1: {
                        required: true
                    },
                    ref_name_1: {
                        required: true
                    },
                    ref_name_2: {
                        required: true
                    },
                    ref_name_3: {
                        required: true
                    },
                    ref_address_1: {
                        required: true
                    },
                    ref_address_2: {
                        required: true
                    },
                    ref_address_3: {
                        required: true
                    },
                    declare_agree: {
                        required: true
                    },
                    thsm: {
                        required: true
                    },
                    pgs: {
                        required: true
                    },

                    //payment
                    card_name: {
                        required: false
                    },
                    card_number: {
                        minlength: 16,
                        maxlength: 16,
                        required: false
                    },
                    card_cvc: {
                        digits: false,
                        required: false,
                        minlength: 3,
                        maxlength: 4
                    },
                    card_expiry_date: {
                        required: false
                    },
                    'payment[]': {
                        required: false,
                        minlength: 1
                    }
                },

                messages: { // custom messages for radio buttons and checkboxes
                    'payment[]': {
                        required: "Please select at least one option",
                        minlength: jQuery.validator.format("Please select at least one option")
                    }
                },

                //form_post_grad_error, form_theology_seminary_error, form_is_english_error
                //form_prof_test_error, form_accomodation_error, form_self_sponsored_error, form_disability_bool_error
                errorPlacement: function (error, element) { // render error placement for each input type
                    if (element.attr("name") == "gender") { // for uniform radio buttons, insert the after the given container
                        error.insertAfter("#form_gender_error");
                    } else if (element.attr("name") == "denomination") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_denomination_error");
                    }
                    else if (element.attr("name") == "school") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_school_error");
                    } else if (element.attr("name") == "is_english") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_is_english_error");
                    } else if (element.attr("name") == "prof_test") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_prof_test_error");
                    } else if (element.attr("name") == "accomodation") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_accomodation_error");
                    } else if (element.attr("name") == "sponsored") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_self_sponsored_error");
                    } else if (element.attr("name") == "campus_site") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_campus_site_error");
                    } else if (element.attr("name") == "disability_bool") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_disability_bool_error");
                    } else if (element.attr("name") == "declare_agree") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_agree_error");
                    } else if (element.attr("name") == "payment[]") { // for uniform checkboxes, insert the after the given container
                        error.insertAfter("#form_payment_error");
                    } else {
                        error.insertAfter(element); // for other inputs, just perform default behavior
                    }

                    //else if (element.attr("name") == "post_grad") { // for uniform checkboxes, insert the after the given container
                    //    error.insertAfter("#form_post_grad_error");
                    //}
                },

                invalidHandler: function (event, validator) { //display error alert on form submit   
                    success.hide();
                    error.show();
                    Metronic.scrollTo(error, -200);
                },

                highlight: function (element) { // hightlight error inputs
                    $(element)
                        .closest('.form-group').removeClass('has-success').addClass('has-error'); // set error class to the control group
                },

                unhighlight: function (element) { // revert the change done by hightlight
                    $(element)
                        .closest('.form-group').removeClass('has-error'); // set error class to the control group
                },

                success: function (label) {
                    if (label.attr("for") == "gender" || label.attr("for") == "payment[]" || label.attr("for") == "denomination") { // for checkboxes and radio buttons, no need to show OK icon
                        label
                            .closest('.form-group').removeClass('has-error').addClass('has-success');
                        label.remove(); // remove error label here
                    } else { // display success icon for other inputs
                        label
                            .addClass('valid') // mark the current input as valid and display OK icon
                            .closest('.form-group').removeClass('has-error').addClass('has-success'); // set success class to the control group
                    }
                },

                submitHandler: function (form) {
                    success.show();
                    error.hide();
                    //add here some ajax code to submit your form or just call form.submit() if you want to submit the form without ajax
                }

            });

            var displayConfirm = function () {
                $('#tab6 .form-control-static', form).each(function () {
                    var input = $('[name="' + $(this).attr("data-display") + '"]', form);
                    if (input.is(":radio")) {
                        input = $('[name="' + $(this).attr("data-display") + '"]:checked', form);
                    }
                    if (input.is(":text") || input.is("textarea")) {
                        $(this).html(input.val());
                    } else if (input.is("select")) {
                        $(this).html(input.find('option:selected').text());
                    } else if (input.is(":radio") && input.is(":checked")) {
                        $(this).html(input.attr("data-title"));
                    } else if ($(this).attr("data-display") == 'payment[]') {
                        var payment = [];
                        $('[name="payment[]"]:checked', form).each(function () {
                            payment.push($(this).attr('data-title'));
                        });
                        $(this).html(payment.join("<br>"));
                    }
                });
            }

            var handleTitle = function (tab, navigation, index) {
                var total = navigation.find('li').length;
                var current = index + 1;
                // set wizard title
                $('.step-title', $('#form_wizard_1')).text('Step ' + (index + 1) + ' of ' + total);
                // set done steps
                jQuery('li', $('#form_wizard_1')).removeClass("done");
                var li_list = navigation.find('li');
                for (var i = 0; i < index; i++) {
                    jQuery(li_list[i]).addClass("done");
                }

                if (current == 1) {
                    $('#form_wizard_1').find('.button-previous').hide();
                    $('#form_wizard_1').find('.button-submit').hide();
                } else {
                    $('#form_wizard_1').find('.button-previous').show();
                }
                // if (current == 3) {
                //     $('#form_wizard_1').find('.button-save').addClass('step3');
                // } else {
                //     $('#form_wizard_1').find('.button-save').removeClass('step3');
                // }

                if (current >= total) {
                    $('#form_wizard_1').find('.button-next').hide();
                    $('#form_wizard_1').find('.button-save').hide();
                    $('#form_wizard_1').find('.button-submit').show();
                    displayConfirm();
                } else {
                    $('#form_wizard_1').find('.button-next').show();
                    $('#form_wizard_1').find('.button-save').show();
                    $('#form_wizard_1').find('.button-submit').hide();
                }
                Metronic.scrollTo($('.page-title'));
            }

            // default form wizard
            $('#form_wizard_1').bootstrapWizard({
                'nextSelector': '.button-next',
                'previousSelector': '.button-previous',
                onTabClick: function (tab, navigation, index, clickedIndex) {
                    return false;
                    // To enable clickable tabs
                    // handleTitle(tab, navigation, clickedIndex);

                },
                onNext: function (tab, navigation, index) {
                    var current = index + 1;
                    var total = navigation.find('li').length;
                    // success.hide();
                    // error.hide();
                    //
                    ////VALIDATION ON EVERY NEXT STEP
                    console.log("Current tab => " + current);
                    console.log("Total tabs => " + total);
                    // if(current == 5 || current == 1 || current == 3){
            
                    // }
                    // else{
                    //    if (form.valid() == false) {
                    //        return false;
                    //    }
                    // }

                    handleTitle(tab, navigation, index);
                },
                onPrevious: function (tab, navigation, index) {
                    success.hide();
                    error.hide();

                    handleTitle(tab, navigation, index);
                },
                onTabShow: function (tab, navigation, index) {
                    var total = navigation.find('li').length;
                    var current = index + 1;
                    var $percent = (current / total) * 100;
                    $('#form_wizard_1').find('.progress-bar').css({
                        width: $percent + '%'
                    });
                }
            });

            //Form Submission
            // SAVE FORM
            $('#form_wizard_1').find('.button-previous').hide();//button-next

            //On next Querry database for file and replace
            $('#form_wizard_1 .button-next').click(function () {
                console.log("Btn Next");
                var nextBaseUrl = './jsondata?view=828:0';
                $.ajax({
                    cache: false,
                    url: nextBaseUrl,
                    type: 'GET',
                    dataType: "json",
                    success: function (data) {
                        console.log("Session data  .button-next ==> " + JSON.stringify(data));
                        var appIdentification = data[0].application_id;
                        console.log("Session data  .button-next appIdentification ==> " + appIdentification);

                        // var fileUrl = '/jsondata?view=828:0:0&data='+ appIdentification;
                        var fileUrl = nextBaseUrl + ':0&data=' + appIdentification;
                        console.log("BTN NEXT  Application ID==> " + appIdentification);
                        console.log("BTN NEXT  declare_agree==> " + declare_agree);
                        var isPaid = data[0].paid;
                        $.ajax({
                            cache: false,
                            url: fileUrl,
                            type: 'GET',
                            dataType: "json",
                            success: function (data) {
                                var downlaodFileUrl = '';
                                var htmlDis = '';
                                var fileBaseUrl = './barazafiles?view=828:0:0';
                                //hide any alerts
                                success.hide();
                                error.hide();
                                successProgress.hide();
                                console.log("FILE DATA ===================> " + JSON.stringify(data));
                                for (var i = 0; i < data.length; i++) {
                                    if (data[i].narrative == "instituteCertUrl_1") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Certificate 1</a></span>';
                                        $('#institutionOneCertUploaded').html(htmlDis);
                                        $('#institutionOneCertUploadedShow').html(htmlDis);
                                    }

                                    if (data[i].narrative == "instituteCertUrl_2") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Certificate 2</a></span>';
                                        $('#institutionTwoCertUploaded').html(htmlDis);
                                        $('#institutionTwoCertUploadedShow').html(htmlDis);
                                    }

                                    if (data[i].narrative == "instituteCertUrl_3") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Certificate 3</a></span>';
                                        $('#institutionThreeCertUploaded').html(htmlDis);
                                        $('#institutionThreeCertUploadedShow').html(htmlDis);
                                    }

                                    if (data[i].narrative == "instituteTransUrl_1") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Transcript 1</a></span>';
                                        $('#institutionOneTransUploaded').html(htmlDis);
                                        $('#institutionOneTransUploadedShow').html(htmlDis);
                                    }

                                    if (data[i].narrative == "instituteTransUrl_2") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Transcript 2</a></span>';
                                        $('#institutionTwoTransUploaded').html(htmlDis);
                                        $('#institutionTwoTransUploadedShow').html(htmlDis);
                                    }

                                    if (data[i].narrative == "instituteTransUrl_3") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Transcript 3</a></span>';
                                        $('#institutionThreeTransUploaded').html(htmlDis);
                                        $('#institutionThreeTransUploadedShow').html(htmlDis);
                                    }

                                    if (data[i].narrative == "profile_image") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Image</a></span>';
                                        $('#profImageUploaded').html(htmlDis);
                                        $('#profImageUploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#profileImage').hide();
                                        }
                                    }
                                    if (data[i].narrative == "purpose_letter") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Purpose Letter</a></span>';
                                        $('#purposeSlipUploaded').html(htmlDis);
                                        $('#purposeSlipUploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#profileImage').hide();
                                        }
                                    }
                                    if (data[i].narrative == "english_cert_slip") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View English Cert</a></span>';
                                        $('#englishCertuploaded').html(htmlDis);
                                        $('#englishCertUploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#profileImage').hide();
                                        }
                                    }
                                    if (data[i].narrative == "appointment_slip") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Appointment Letter</a></span>';
                                        $('#appointmentSlipUploaded').html(htmlDis);
                                        $('#appointmentSlipUploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#appointmentSlip').hide();
                                        }

                                    }
                                    if (data[i].narrative == "cv_slip") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded CV</a></span>';
                                        $('#cvSlipUploaded').html(htmlDis);
                                        $('#cvSlipUploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#cvSlip').hide();
                                        }
                                    }
                                    if (data[i].narrative == "identification_slip") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded National Identity Card or Passport</a></span>';
                                        $('#identificationSlipUploaded').html(htmlDis);
                                        $('#identificationSlipUploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#identificationSlip').hide();
                                        }
                                    }
                                    if (data[i].narrative == "ref_one_letter") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Recommendation</a></span>';
                                        $('#ref1Uploaded').html(htmlDis);
                                        $('#ref1UploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#identificationSlip').hide();
                                        }
                                    }
                                    if (data[i].narrative == "ref_two_letter") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Recommendation</a></span>';
                                        $('#ref2Uploaded').html(htmlDis);
                                        $('#ref2UploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#identificationSlip').hide();
                                        }
                                    }
                                    if (data[i].narrative == "ref_three_letter") {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="' + downlaodFileUrl + '" style="text-decoration:none;color: #fff;">View Uploaded Recommendation</a></span>';
                                        $('#ref3Uploaded').html(htmlDis);
                                        $('#ref3UploadedShow').html(htmlDis);
                                        if (declare_agree !== undefined && declare_agree !== null) {
                                            //$('#identificationSlip').hide();
                                        }
                                    }
                                    if (data[i].narrative == "bank_slip" && isPaid == 'f') {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<div class="col-sm-12 col-md-12">'
                                            + '<div class="alert alert-success">Upload Successful. Kindly wait for approval to continue</div>'
                                            + '</div>';
                                        $("#updatePaymentNotification").html(htmlDis);
                                    }
                                    if (data[i].narrative == "sponsor_slip" && isPaid == 'f') {
                                        downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                        htmlDis = '<div class="col-sm-12 col-md-12">'
                                            + '<div class="alert alert-success">Upload Successful. Kindly wait for approval to continue</div>'
                                            + '</div>';
                                        $("#updatePaymentNotification").html(htmlDis);
                                    }

                                    downlaodFileUrl = fileBaseUrl + '&fileid=' + data[i].sys_file_id;
                                    console.log(i + "BTN NEXT . sys_file_id ===================> " + data[i].sys_file_id);
                                    console.log(i + "BTN NEXT . narrative ===================> " + data[i].narrative);
                                    console.log(i + "BTN NEXT . downloadfileUrl ===================> " + downlaodFileUrl);
                                    // $('#form_wizard_1').find('.button-next').show().removeClass('disabled');
                                }
                            }
                        });
                    },
                    error: function (r) {
                        //alert('Error! Please try again.' + r.responseText);
                        // console.log(r);
                    }
                });
            }).hide();

            //ON FORM SUBMISSION
            $('#form_wizard_1 .button-submit').click(function () {
                //get session to check for data
                $.ajax({
                    cache: false,
                    url: './jsondata?view=828:0',
                    type: 'GET',
                    dataType: "json",
                    success: function (data) {
                        console.log("Getting session data ==> " + JSON.stringify(data));
                        var appIdentification = data[0].application_id;
                        var fileUrl = './jsondata?view=828:0:0&data=' + appIdentification;

                        //Querry for file
                        $.ajax({
                            cache: false,
                            url: fileUrl,
                            type: 'GET',
                            dataType: "json",
                            success: function (data) {

                                var errorHtml = '';
                                var profFLag = 0, purpFlag = 0, cvFlag = 0, idFlag = 0, ref1Flag = 0, ref2Flag = 0, ref3Flag = 0;
                                errorHtml += "<span><b>Failed Submission!</b> Correct the following errors.</span><ul>";

                                //check for required documents
                                for (var i = 0; i < data.length; i++) {
                                    if (data[i].narrative == 'profile_image') {
                                        profFLag = 1;
                                        console.log('Narrative Profile ' + data[i].narrative);
                                    }
                                    if (data[i].narrative == "purpose_letter") {
                                        purpFlag = 1;
                                        console.log('Narrative Purpose ' + data[i].narrative);
                                    }
                                    if (data[i].narrative == "cv_slip") {
                                        cvFlag = 1;
                                        console.log('Narrative CV ' + data[i].narrative);
                                    }
                                    if (data[i].narrative == "identification_slip") {
                                        idFlag = 1;
                                        console.log('Narrative ID/Passport ' + data[i].narrative);
                                    }
                                    if (data[i].narrative == "ref_one_letter") {
                                        ref1Flag = 1;
                                        console.log('Narrative Reference one ' + data[i].narrative);
                                    }
                                    if (data[i].narrative != "ref_two_letter") {
                                        ref2Flag = 1;
                                        console.log('Narrative Reference two ' + data[i].narrative);
                                    }
                                    if (data[i].narrative == "ref_three_letter") {
                                        ref3Flag = 1;
                                        console.log('Narrative Reference three ' + data[i].narrative);
                                    }
                                }
                                //Check for error Prevent multi-writing
                                if (profFLag == 0) {
                                    errorHtml += "<li>Profile Image not uploaded</li>";
                                }
                                if (purpFlag == 0) {
                                    errorHtml += "<li>Purpose Letter not uploaded</li>";
                                }
                                if (cvFlag == 0) {
                                    errorHtml += "<li>CV missing</li>";
                                }
                                if (idFlag == 0) {
                                    errorHtml += "<li>ID/Passport not uploaded</li>";
                                }
                                if (ref1Flag == 0) {
                                    errorHtml += "<li>Reference Letter for 1st referee not uploaded</li>";
                                }
                                if (ref2Flag == 0) {
                                    errorHtml += "<li>Reference Letter for 2nd referee not uploaded</li>";
                                }
                                if (ref3Flag == 0) {
                                    errorHtml += "<li>Reference Letter for 3rd referee not uploaded</li>";
                                }
                                errorHtml += "</ul>";
                                //If any of them has error
                                if (profFLag == 0 || purpFlag == 0 || cvFlag == 0 || idFlag == 0 || ref1Flag == 0 || ref2Flag == 0 || ref3Flag == 0) {
                                    success.hide();
                                    error.show();
                                    Metronic.scrollTo(error, -200);
                                    $('#failedSubmission').html(errorHtml);
                                } else {
                                    //SUBMIT FORM
                                    console.log("Check Compulsory Fields submission");
                                    if (form.valid() == false) {
                                        console.log("FALSE");
                                        return false;
                                    }

                                    var json = $('#submit_form_1').serializeArray();
                                    var jsonData = {};

                                    $.each(json, function (i, field) {
                                        jsonData[field.name] = field.value;
                                    });
                                    //old URL
                                    //var saveUrl = "/ajaxupdate?view=828:0&KF="+args[0]+"&oper=edit&form_data="+JSON.stringify(jsonData);
                                    //Working Url
                                    var saveUrl = "./formdata?view=828:0&KF=" + args[0] + "&oper=submit";
                                    //var saveUrl = "/formdata";
                                    console.log("Sending Data=>" + JSON.stringify(jsonData));

                                    $.post(saveUrl, { tag: "application", form_data: JSON.stringify(jsonData) }, function (data) {
                                        //console.log("Response on success============>" + JSON.parse(data));
                                        console.log("Response on success============>" + JSON.stringify(data));
                                        var retStatus = JSON.parse(data);
                                        console.log("Response on statsu ============>" + retStatus.status);

                                        if (retStatus.status == "OK") {
                                            success.show();
                                            error.hide();
                                            Metronic.scrollTo(success, -200);
                                            console.log("success");
                                            $('#form_wizard_1').find('.button-submit').hide();
                                            //Hide Action Buttons
                                            $('#form-actions').hide();
                                        }
                                        // else if(retStatus.status == "Failed"){
                                        else{
                                            success.hide();
                                            error.show();
                                            Metronic.scrollTo(error, -200);
                                            console.log("fail");
                                        }
                                    });

                                }
                            }//end file url
                        });//end file url
                    },
                    error: function (r) {
                        //alert('Error! Please try again.' + r.responseText);
                        // console.log(r);
                    }
                });


            }).hide();

            //apply validation on select2 dropdown value change, this only needed for chosen dropdown integration.
            $('#country_list', form).change(function () {
                form.validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
            });

            //date
            $('#dob').datepicker({
                "setDate": new Date(),
                format: 'mm-dd-yyyy',
                autoclose: true
            });

            $('.date').datepicker({
                "setDate": new Date(),
                format: 'mm/dd/yyyy',
                autoclose: true
            });

            $('.years').datepicker({
                "setDate": new Date(),
                format: 'yyyy',
                startView: "years",
                minViewMode: "years",
                autoclose: true
            });
        }

    };

}();

var FormSaveProgress = function () {
    console.log("==============Clicked Save Button Before============>");
    var args = {};
    return {
        //main function to initiate the module
        init: function (Args) {
            args = Args;

            var form = $('#submit_form_1');
            var error = $('.alert-danger', form);
            var errorServer = $('.alert-danger-server', form);
            var success = $('.progress-step', form);


            $('#form_wizard_1 .button-save').click(function () {
                console.log("==============Clicked Save Button============>");
                var json = $('#submit_form_1').serializeArray();
                var jsonData = {};
                $.each(json, function (i, field) {
                    jsonData[field.name] = field.value;
                });
                var saveUrl = "./formdata?view=828:0&KF=" + args[0] + "&oper=save";
                console.log(jsonData);
                $.post(saveUrl, { tag: "application", form_data: JSON.stringify(jsonData) }, function (data) {
                    //console.log("Response on success============>" + JSON.parse(data));
                    console.log("Response on success============>" + JSON.stringify(data));
                    var retStatus = JSON.parse(data);
                    console.log("Response on statsu ============>" + retStatus.status);

                    if (retStatus.status == "OK") {
                        success.show();
                        error.hide();
                        Metronic.scrollTo(success, -200);
                        console.log("success");
                    }
                    // else if(retStatus.status == "Failed"){
                    else {
                        success.hide();
                        error.show();
                        Metronic.scrollTo(error, -200);
                        console.log("fail");
                    }
                });
            });
        }
    };
}();
//Post Pay
$('#paypal').click(function () {
    //Configure Paypal Button
    var paypalID = $('#paypal');
    paypalID.removeClass('pay-default'); //will remove the class
    paypalID.addClass('pay-border');  //will add the class
    var tick = '<i class="fa fa-paypal"></i>'
        + '<div> Paypal </div>'
        + '<span class="badge badge-pay" >'
        + '<i class="fa fa-check"></i> </span>';
    paypalID.html(tick);

    //Configure SPonsor Button
    var sponsorID = $('#sponsorship');
    sponsorID.addClass('pay-default'); //will remove the class
    sponsorID.removeClass('pay-border');  //will add the class
    var removeTick = '<i class="fa fa-group"></i>'
        + '<div> Sponsors </div>';
    sponsorID.html(removeTick);

    var pay = { "payment": "paypal" };
    $.ajax({
        cache: false,
        url: '/post/pay',
        type: 'POST',
        dataType: "json",
        data: JSON.stringify({ Payment: pay }),
        success: function (data) {

        },
        error: function (r) {
            //alert('Error! Please try again.' + r.responseText);
            console.log(r);
        }
    });
});

$('#sponsorship').click(function () {
    //Configure Sponsor Button
    var sponsorID = $('#sponsorship');
    sponsorID.removeClass('pay-default'); //will remove the class
    sponsorID.addClass('pay-border');  //will add the class
    var tick = '<i class="fa fa-group"></i>'
        + '<div> Sponsors </div>'
        + '<span class="badge badge-pay" >'
        + '<i class="fa fa-check"></i> </span>';
    sponsorID.html(tick);

    //Configure Paypal Button
    var paypal = $('#paypal');
    paypal.addClass('pay-default'); //will remove the class
    paypal.removeClass('pay-border');  //will add the class
    var removeTick = '<i class="fa fa-paypal"></i>'
        + '<div> Paypal </div>';
    paypal.html(removeTick);

    var pay = { "payment": "sponsorship" };
    $.ajax({
        cache: false,
        url: '/post/pay',
        type: 'POST',
        dataType: "json",
        data: JSON.stringify({ Payment: pay }),
        success: function (data) {

        },
        error: function (r) {
            //alert('Error! Please try again.' + r.responseText);
            console.log(r);
        }
    });
});


