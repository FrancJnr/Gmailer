/// Jquery validate newsletter
jQuery(document).ready(function(){

    $('#newsletter').submit(function(){

        var action = $(this).attr('action');

        $("#message-newsletter").slideUp(750,function() {
            $('#message-newsletter').hide();

            $('#submit-newsletter')
                .after('<i class="icon-spin4 animate-spin loader"></i>')
                .attr('disabled','disabled');

            $.post(action, {
                    email_newsletter: $('#email_newsletter').val()
                },
                function(data){
                    document.getElementById('message-newsletter').innerHTML = data;
                    $('#message-newsletter').slideDown('slow');
                    $('#newsletter .loader').fadeOut('slow',function(){$(this).remove()});
                    $('#submit-newsletter').removeAttr('disabled');
                    if(data.match('success') != null) $('#newsletter').slideUp('slow');

                }
            );

        });

        return false;

    });

});

// Jquery validate form contact home
jQuery(document).ready(function(){

    $('#contactform_home').submit(function(){

        var action = $(this).attr('action');

        $("#message-contact-home").slideUp(750,function() {
            $('#message-contact-home').hide();

            $('#submit-contact-home')
                .after('<i class="icon-spin4 animate-spin loader"></i>')
                .attr('disabled','disabled');

            $.post(action, {
                    name_contact_home: $('#name_contact_home').val(),
                    email_contact_home: $('#email_contact_home').val(),
                    phone_contact_home: $('#phone_contact_home').val(),
                    course_home: $('#course_home').val()
                },
                function(data){
                    document.getElementById('message-contact-home').innerHTML = data;
                    $('#message-contact-home').slideDown('slow');
                    $('#contactform_home .loader').fadeOut('slow',function(){$(this).remove()});
                    $('#submit-contact-home').removeAttr('disabled');
                    if(data.match('success') != null) $('#contactform_home').slideUp('slow');

                }
            );

        });

        return false;

    });
});
// Jquery validate form contact
jQuery(document).ready(function(){

    $('#contactform').submit(function(){

        var action = $(this).attr('action');

        $("#message-contact").slideUp(750,function() {
            $('#message-contact').hide();

            $('#submit-contact')
                .after('<i class="icon-spin4 animate-spin loader"></i>')
                .attr('disabled','disabled');

            $.post(action, {
                    name_contact: $('#name_contact').val(),
                    lastname_contact: $('#lastname_contact').val(),
                    email_contact: $('#email_contact').val(),
                    phone_contact: $('#phone_contact').val(),
                    message_contact: $('#message_contact').val(),
                    verify_contact: $('#verify_contact').val()
                },
                function(data){
                    document.getElementById('message-contact').innerHTML = data;
                    $('#message-contact').slideDown('slow');
                    $('#contactform .loader').fadeOut('slow',function(){$(this).remove()});
                    $('#submit-contact').removeAttr('disabled');
                    if(data.match('success') != null) $('#contactform').slideUp('slow');

                }
            );

        });

        return false;

    });
});

// Jquery validate form visit
jQuery(document).ready(function(){

    $('#visit').submit(function(){

        var action = $(this).attr('action');

        $("#message-visit").slideUp(750,function() {
            $('#message-visit').hide();

            $('#submit-visit')
                .after('<i class="icon-spin4 animate-spin loader"></i>')
                .attr('disabled','disabled');

            $.post(action, {
                    name_visit: $('#name_visit').val(),
                    lastname_visit: $('#lastname_visit').val(),
                    email_visit: $('#email_visit').val(),
                    phone_visit: $('#phone_visit').val(),
                    date_visit: $('#date_visit').val(),
                    time_visit: $('#time_visit').val()
                },
                function(data){
                    document.getElementById('message-visit').innerHTML = data;
                    $('#message-visit').slideDown('slow');
                    $('#visit .loader').fadeOut('slow',function(){$(this).remove()});
                    $('#submit-visit').removeAttr('disabled');
                    if(data.match('success') != null) $('#visit').slideUp('slow');

                }
            );

        });

        return false;

    });
});

/**
 * Created by Evin on 9/11/2017.
 */


$(window).on("load", GetAllProperties);

function GetAllProperties() {
     //jQuery cross domain ajax
    $.ajax({
       cache: false,
       url: './jsongeneral?xml=web/general.xml&view=18:0',
       type: 'GET',
       dataType: "json",
       success: function (data) {
           var masters = 'Masters';
           var doctorateMinistryCourses='Doctor of Ministry';
           var philosophyMinistryCourses='Doctor of Philosophy';
           var doctorateCourses='';
           var mastersCourses='';
           var philosophyCourses='';
    
           mastersCourses += '<ul>';
           doctorateCourses += '<ul>';
           philosophyCourses += '<ul>';
           console.log("String for courses " + JSON.stringify(data));
           Object.keys(data).forEach(function(value, key) {
    
               //courses += data[value].degree_name
               //courses += data[value].degree_level_name
               //+ ' ,';
               if(data[value].degree_level_name == masters){
                   mastersCourses += '<li>'
                       +'<div><a href="'+data[value].CL+'"><figure><img   src="./assets/img/course_3_thumb.jpg" alt="" class="img-rounded"></figure>'
                       +' <h3>'+ data[value].degree_name +'</h3><small>Start 3 October 2015</small></a></div>'
                       +'</li>';
               }else if(data[value].degree_level_name == doctorateMinistryCourses){
                   doctorateCourses += '<li>'
                       +'<div><a href="'+data[value].CL+'"><figure><img   src="./assets/img/course_3_thumb.jpg" alt="" class="img-rounded"></figure>'
                       +' <h3>'+ data[value].degree_name +'</h3><small>Start 3 October 2015</small></a></div>'
                       +'</li>';
               }else if(data[value].degree_level_name == philosophyMinistryCourses){
                   philosophyCourses += '<li>'
                       +'<div><a href="'+data[value].CL+'"><figure><img   src="./assets/img/course_3_thumb.jpg" alt="" class="img-rounded"></figure>'
                       +' <h3>'+ data[value].degree_name +'</h3><small>Start 3 October 2015</small></a></div>'
                       +'</li>';
               }
    
           });
           doctorateCourses += '</ul>';
           mastersCourses += '</ul>';
           philosophyCourses += '</ul>';
    
           $("#appendMastersCourses").html(mastersCourses);
           $("#appendDoctorateMinistryCourses").html(doctorateCourses);
           $("#appendDoctoratePhilosophyCourses").html(philosophyCourses);
    
       },
       error: function (r) {
           //alert('Error! Please try again.' + r.responseText);
           console.log(r);
       }
    });


    // var data;
    // var masters = 'Masters';
    // var doctorateMinistryCourses='Doctor of Ministry';
    // var philosophyMinistryCourses='Doctor of Philosophy';
    // var doctorateCourses='';
    // var mastersCourses='';
    // var philosophyCourses='';
    // data = [
    //     {
    //         "degree_id": "AFTR",
    //         "degree_name": "Master of Arts in Missiology (ATR)",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=AFTR",
    //         "KF": "AFTR"
    //     },
    //     {
    //         "degree_id": "CHAP",
    //         "degree_name": "Master of Chaplaincy",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=CHAP",
    //         "KF": "CHAP"
    //     },
    //     {
    //         "degree_id": "DMin",
    //         "degree_name": "Doctor of Ministry",
    //         "degree_level_name": "Doctor of Ministry",
    //         "CL": "?view=18:0:0&data=DMin",
    //         "KF": "DMin"
    //     },
    //     {
    //         "degree_id": "LEAD",
    //         "degree_name": "Doctor of Philosophy",
    //         "degree_level_name": "Doctor of Philosophy",
    //         "CL": "?view=18:0:0&data=LEAD",
    //         "KF": "LEAD"
    //     },
    //     {
    //         "degree_id": "MABTS",
    //         "degree_name": "Master of Arts in Biblical and Theological Studies",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=MABTS",
    //         "KF": "MABTS"
    //     },
    //     {
    //         "degree_id": "MAR",
    //         "degree_name": "Master of Arts      ",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=MAR",
    //         "KF": "MAR"
    //     },
    //     {
    //         "degree_id": "MBA",
    //         "degree_name": "Master of Business Administration",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=MBA",
    //         "KF": "MBA"
    //     },
    //     {
    //         "degree_id": "MDiv",
    //         "degree_name": "Master of Divinity",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=MDiv",
    //         "KF": "MDiv"
    //     },
    //     {
    //         "degree_id": "ML",
    //         "degree_name": "Master of Arts in Leadership",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=ML",
    //         "KF": "ML"
    //     },
    //     {
    //         "degree_id": "MM",
    //         "degree_name": "Master of Arts in Missiology ",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=MM",
    //         "KF": "MM"
    //     },
    //     {
    //         "degree_id": "MPH",
    //         "degree_name": "Master of Public Health",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=MPH",
    //         "KF": "MPH"
    //     },
    //     {
    //         "degree_id": "MPTh",
    //         "degree_name": "Master of Arts in Pastoral Theology",
    //         "degree_level_name": "Masters",
    //         "CL": "?view=18:0:0&data=MPTh",
    //         "KF": "MPTh"
    //     }
    // ];
    // mastersCourses += '<ul>';
    // doctorateCourses += '<ul>';
    // philosophyCourses += '<ul>';
    // Object.keys(data).forEach(function(value, key) {

    //     //courses += data[value].degree_name
    //     //courses += data[value].degree_level_name
    //     //+ ' ,';
    //     if(data[value].degree_level_name == masters){
    //         mastersCourses += '<li>'
    //             +'<div><a  class="selector" href="'+data[value].CL+'"><figure><img src="./assets/img/course_3_thumb.jpg" alt="" class="img-rounded"></figure>'
    //             +' <h3>'+ data[value].degree_name +'</h3><small>Start 3 October 2015</small></a></div>'
    //             +'</li>';
    //     }else if(data[value].degree_level_name == doctorateMinistryCourses){
    //         doctorateCourses += '<li>'
    //             +'<div><a  class="selector" href="#"><figure><img src="./assets/img/course_3_thumb.jpg" alt="" class="img-rounded"></figure>'
    //             +' <h3>'+ data[value].degree_name +'</h3><small>Start 3 October 2015</small></a></div>'
    //             +'</li>';
    //     }else if(data[value].degree_level_name == philosophyMinistryCourses){
    //         philosophyCourses += '<li>'
    //             +'<div><a  class="selector" href="#"><figure><img src="./assets/img/course_3_thumb.jpg" alt="" class="img-rounded"></figure>'
    //             +' <h3>'+ data[value].degree_name +'</h3><small>Start 3 October 2015</small></a></div>'
    //             +'</li>';
    //     }

    // });
    // doctorateCourses += '</ul>';
    // mastersCourses += '</ul>';
    // philosophyCourses += '</ul>';

    // $("#appendMastersCourses").html(mastersCourses);
    // $("#appendDoctorateMinistryCourses").html(doctorateCourses);
    // $("#appendDoctoratePhilosophyCourses").html(philosophyCourses);

    // $('.selector').qtip({
    //     content: {
    //         title: {
    //             text: 'Master of Arts in Leadership',
    //             button: true
    //         },
    //         text: 'The Master of Arts in Leadership (MAL) Program is an interdisciplinary, collaborative, post-graduate program designed to meet the needs of mid-career leaders.'

    //     },
    //     hide: {
    //         event: 'click',
    //         inactive: 3000,
    //         delay: 300
    //     },
    //     style: 'wiki'
    //     //content: {
    //     //    text: function(event, api) {
    //     //        $.ajax({
    //     //            url: 'http://qtip2.com/demos/data/owl',
    //     //        })
    //     //            .then(function(content){
    //     //                api.set('content.text', content);
    //     //            },
    //     //            function(xhr, status, error) {
    //     //                // Upon failure... set the tooltip content to the status and error value
    //     //                api.set('content.text', status + ': ' + error);
    //     //            });
    //     //
    //     //        return 'Loading...';
    //     //    }
    //     //},
    //     //position: {
    //     //    viewport: $(window)
    //     //},
    //     //hide: {
    //     //    fixed: true,
    //     //    delay: 300
    //     //},
    //     //style: 'wiki'
    // });

}


jQuery(document).ready(function(){
    //$('#selector').qtip({
    //    content: {
    //        text: 'Loading...', // Loading text...
    //        ajax: {
    //            url: './jsongeneral?xml=web/general.xml&view=18:0', // URL to the JSON script
    //            type: 'GET', // POST or GET
    //            data: { id: 3 }, // Data to pass along with your request
    //            dataType: 'json', // Tell it we're retrieving JSON
    //            success: function(data, status) {
    //                /* Process the retrieved JSON object
    //                 * Retrieve a specific attribute from our parsed
    //                 * JSON string and set the tooltip content.
    //                 */
    //                var content = 'Demo ' + data[0].degree_name ;
    //
    //                // Now we set the content manually (required!)
    //                this.set('content.text', content);
    //            }
    //        }
    //    }
    //});

});
