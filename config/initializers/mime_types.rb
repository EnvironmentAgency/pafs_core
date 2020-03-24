# frozen_string_literal: true

unless defined? Mime::XLSX
  Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
end
