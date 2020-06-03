# frozen_string_literal: true

FactoryBot.define do
  factory :area_download, class: PafsCore::AreaDownload do
    area
    user

    %i[complete empty ready generating failed].each do |state|
      trait state do
        status { state }
      end
    end
  end
end
