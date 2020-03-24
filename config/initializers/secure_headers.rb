# frozen_string_literal: true

require "secure_headers"

# Added in response to initial PEN test requiring we specify a
# Content-Security-Policy. A CSP is
# > delivered via a HTTP response header, much like HSTS, and defines
# > approved sources of content that the browser may load. It can be an
# > effective countermeasure to Cross Site Scripting (XSS) attacks and is
# > also widely supported and usually easily deployed.
# https://scotthelme.co.uk/content-security-policy-an-introduction/
#
# See the following for reference on CSP
# https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
#
# See the following for reference on secure_headers and its configuration
# https://github.com/twitter/secureheaders#configuration
SecureHeaders::Configuration.default do |config|
  # Specifically here we are saying
  # - scripts can only come from the service or Google, however we permit
  #   unsafe-inlinescripts (Google to support analytics)
  # - images can only come from the service and Google (GA because it sends
  #   the data to the Analytics server via a list of parameters attached to
  #   a single-pixel image request)
  # - fonts can only come from the service, or via the data: scheme
  # - send any violation reports to a service we have setup for CSP
  # - for all other items their soiurce must be the service (default-src)
  #
  # The following were used for reference
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/script-src
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/font-src
  config.csp = {
    default_src: %w['self'],
    font_src: %w['self' data:],
    img_src: %w['self' www.google-analytics.com],
    object_src: %w['self'],
    script_src: %w['self' 'unsafe-inline' www.googletagmanager.com www.google-analytics.com],
    style_src: %w['self'],
    report_uri: %w[https://environmentagency.report-uri.io/r/default/csp/enforce]
  }

  # TODO: These have been set to match the headers we were currently using at
  # the time of implementing securer headers. We should review if they match
  # match secure headers defaults, which give a good level security
  config.x_content_type_options = "nosniff"
  config.x_frame_options = "SAMEORIGIN"
  config.x_xss_protection = "1; mode=block"

  # TODO: If no values were passed in Secure headers would set these to its
  # defaults. The issue was at time of implementing we were not using these
  # headers, and felt that setting them was outside the scope of adding a
  # Content-Security-Policy header. We need to come back to them though and
  # check if there would be any issues using Secure Headers defaults, which
  # would make the site more secure.
  config.hsts = SecureHeaders::OPT_OUT # Strict-Transport-Security
  config.x_download_options = SecureHeaders::OPT_OUT
  config.x_permitted_cross_domain_policies = SecureHeaders::OPT_OUT
end
