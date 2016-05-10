// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function showImage() {
    document.getElementById('imageDiv').style.display = "block";
    document.getElementById('textDiv').style.display = "none";
}

function showPlainText() {
    document.getElementById('imageDiv').style.display = "none";
    document.getElementById('textDiv').style.display = "block";
    $("word").css("background-image", "url()");
    $("word").css("color", "black")
}

function showReflow(id, page) {
    document.getElementById('imageDiv').style.display = "none";
    document.getElementById('textDiv').style.display = "block";
    $("word").css("background-image", "url(/book/"+id+"/page/"+page+"/image)");
    $("word").css("color", "rgba(0,0,0,0)")
}
