# frozen_string_literal: true
require "rails_helper"

RSpec.describe "there is a global library version", type: :feature do
  it "has the format n.n.n" do
    expect(PafsCore::VERSION).to match /\A\d\.\d\.\d\Z/
  end
end
