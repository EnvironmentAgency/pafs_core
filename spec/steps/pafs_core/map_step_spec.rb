# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::MapStep, type: :model do
  before(:all) { @tempfile = Tempfile.new }
  after(:all) { @tempfile.close! }

  describe "attributes" do
    subject { FactoryGirl.build(:map_step) }

    it_behaves_like "a project step"
  end

  describe "#benefit_area" do
    subject { FactoryGirl.build(:map_step) }

    context "when there is a defined benefit_area" do
      it "should get the correct benefit area" do
        expect(subject.benefit_area).to eq("[[432123, 132453], [444444, 134444], [456543, 123432]]")
      end
    end

    context "when the benefit_area is set to nil" do
      it "should get \"[[[]]]\"" do
        subject.benefit_area = nil
        expect(subject.benefit_area).to eq "[[[]]]"
      end
    end
  end

  describe "#benefit_area_centre" do
    subject { FactoryGirl.build(:map_step) }

    context "when the benefit_area_centre is set" do
      it "should get the correct benefit_area_centre" do
        expect(subject.benefit_area_centre).to eq %w(457733 221751)
      end
    end

    context "when the benefit_area_centre is not set" do
      it "should get project_location instead" do
        subject.benefit_area_centre = nil
        subject.project.project_location = [457736, 221754]
        subject.project.save

        expect(subject.benefit_area_centre).to eq %w(457736 221754)
      end
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:map_step) }
    let(:params) {
      HashWithIndifferentAccess.new({
        map_step: {
          benefit_area: "[[444444, 222222], [421212, 212121], [432123, 234432]]",
          benefit_area_zoom_level: 3,
          benefit_area_centre: "[\"420000\", \"230000\"]"
        }
      })
    }

    let(:benefit_area_file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "../fixtures/map.png"))) }

    let(:file_params) {
      HashWithIndifferentAccess.new({
        map_step: {
          benefit_area_file: benefit_area_file
        }
      })
    }

    let(:error_params) {
      HashWithIndifferentAccess.new({
        map_step: {
          benefit_area: "",
          benefit_area_centre: nil,
          benefit_area_zoom_level: nil
        }
      })
    }

    it "saves the :benefit_area when benefit_area attributes are valid" do
      expect(subject.benefit_area).not_to eq "[[444444, 222222], [421212, 212121], [432123, 234432]]"
      expect(subject.benefit_area_centre).not_to eq %w(420000 230000)
      expect(subject.benefit_area_zoom_level).not_to eq 3
      expect(subject.update(params)).to be true
      expect(subject.benefit_area).to eq "[[444444, 222222], [421212, 212121], [432123, 234432]]"
      expect(subject.benefit_area_centre).to eq %w(420000 230000)
      expect(subject.benefit_area_zoom_level).to eq 3
    end

    it "saves the benefit area file" do
      expect(subject.update(file_params)).to be true
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end

  describe "#delete_benefit_area_file" do
    let(:benefit_area_file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "../fixtures/map.png"))) }
    subject { FactoryGirl.build(:map_step) }

    context "when an uploaded file exists" do
      it "removes the file from storage" do
        subject.update(map_step: { benefit_area_file: benefit_area_file })
        subject.delete_benefit_area_file
      end

      it "resets the stored file attributes" do
        subject.update(map_step: { benefit_area_file: benefit_area_file })
        expect(subject.benefit_area_file_name).not_to be_nil
        expect(subject.benefit_area_content_type).not_to be_nil
        expect(subject.benefit_area_file_size).not_to be_nil
        expect(subject.benefit_area_file_updated_at).not_to be_nil
        subject.delete_benefit_area_file
        expect(subject.benefit_area_file_name).to be_nil
        expect(subject.benefit_area_content_type).to be_nil
        expect(subject.benefit_area_file_size).to be_nil
        expect(subject.benefit_area_file_updated_at).to be_nil
        expect(subject.virus_info).to be_nil
      end
    end
  end
end
