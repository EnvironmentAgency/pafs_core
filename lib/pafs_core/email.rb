# frozen_string_literal: true
module PafsCore
  module Email
    def prevent_tracking
      headers({
        "X-SMTPAPI" => {
          "filters" => {
            "bypass_list_management" => {
              "settings" => {
                "enable" => 1
              }
            },
            "clicktrack" => {
              "settings" => {
                "enable" => 0
              }
            }
          }
        }.to_json
      })
    end
  end
end
