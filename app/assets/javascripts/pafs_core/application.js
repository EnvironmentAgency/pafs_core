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
//= require_tree .
//= require govuk/all.js
//= require govuk_publishing_components/components/cookie-banner
//= require govuk_publishing_components/lib/cookie-functions
//= require pafs_core/analytics
//= require pafs_core/cookies

window.CookieSettings.start()
window.GOVUK.analyticsInit()
window.GOVUKFrontend.initAll()
