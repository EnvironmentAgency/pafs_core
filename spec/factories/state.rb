FactoryBot.define do
  factory :state, class: PafsCore::State do
    state { "draft" }

    PafsCore::State::VALID_STATES.each do |valid_state|
      trait valid_state.to_sym do
        state { valid_state }
      end
    end
  end
end
