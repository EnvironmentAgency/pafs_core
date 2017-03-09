# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  module CustomHeaders

    # Intended to be used in ApplicationController's, specifically from a
    # before_action() in order to update the response headers.
    def response_headers!(response)
      # Cache buster, specifically we don't want the client to cache any
      # responses from the service
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate, private"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

      # Added in response to initial PEN test. A Content-Security-Policy
      # > is delivered via a HTTP response header, much like HSTS, and defines
      # > approved sources of content that the browser may load. It can be an
      # > effective countermeasure to Cross Site Scripting (XSS) attacks and is
      # > also widely supported and usually easily deployed.
      # https://scotthelme.co.uk/content-security-policy-an-introduction/
      #
      # Specifically here we are saying
      # - scripts can only come from the service, however we permit
      #   unsafe-inlinescripts
      # - fonts can only come from the service, or via the data: scheme
      # - send any violation reports to a service we have setup for CSP
      # - for all other items their soiurce must be the service (default-src)
      #
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/script-src
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/font-src
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
      response
        .headers["Content-Security-Policy"] = "default-src 'self'; "\
                                              "script-src 'self' 'unsafe-inline'; "\
                                              "font-src 'self' data:; "\
                                              "report-uri https://environmentagency.report-uri.io/r/default/csp/enforce"
    end

  end
end
