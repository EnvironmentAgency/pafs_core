function FundingContributorValuesTable(tableElement) {
  var self = this;
  this.table = tableElement;
  this.grandTotalElement = this.table.find("td.grand-total").first;

  self.initialise = function() {
    this.table.find(".amount input").on("change", self.updateTotals.bind(this));
  }

  self.updateTotals = function() {
    var total = 0;
    this.table.find(".amount input").each(function(_index, inputElement) {
      var value = Number($(inputElement).val());
      if (isNaN(value)) { next }

      total += value;
    })

    this.table.find(".grand-total").text(total);
  }
}

$(function() {
  $("table.funding-contributor-table").each(function(_index, table) {
    var funding_values_table = new FundingContributorValuesTable($(table));
    funding_values_table.initialise();
    funding_values_table.updateTotals();
  });
});
