function PartnershipFundingCalcUploadSelector(instructions_selector) {
  var self = this;
  var selector = instructions_selector;

  self.showSection = function(section_name) {
    $(selector).find('.download-instructions').hide();
    $(selector).find('.' + section_name + '.download-instructions').show();
    $(selector).find('.upload-section').show();
  }

  self.valueChanged = function(event) {
    self.showSection($(event.target).val());
    $(selector).find('.upload-section').show();
  }

  self.initialise = function() {
    $(selector).find("input[type='radio']").on('change', self.valueChanged);
    $(selector).find('.download-instructions').hide();
    $(selector).find('.upload-section').hide();

    var selected_section = $("input[type='radio'][name='funding_calculator_step[expected_version]'][checked='checked']").val();

    if (selected_section) {
      self.showSection(selected_section);
    }
  }
}

$(function() {
  var pfc_upload_selector = new PartnershipFundingCalcUploadSelector(".edit_funding_calculator_step");
  pfc_upload_selector.initialise();
})
