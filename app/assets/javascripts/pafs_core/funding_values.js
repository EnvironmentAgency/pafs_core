function FundingValuesTable(table_selector) {
  var self = this;
  var selector = table_selector;

  self.updateTotals = function() {
    var row_count = $(selector).find("tbody > tr").length;
    for(var i = 0; i < row_count; i++) {
      self.updateRowTotal(i + 1);
    }

    var col_count = $(selector).find("tbody > tr:first-child > td").length;
    for(var i = 1; i < col_count - 1; i++) {
      self.updateColumnTotal(i + 1);
    }

    self.updateGrandTotal();
  }

  self.updateRowTotal = function(row) {
    var values = [];
    $(selector).find("tbody > tr:nth-child(" + row + ") > td").each(function() {
      push_field_value(this, values);
    });
    $(selector).find("tbody > tr:nth-child(" + row + ") > td:last-child").text(format_number(sum_array(values)));
  }

  self.updateColumnTotal = function(column) {
    var values = [];
    $(selector).find("tbody > tr > td:nth-child(" + column + ")").each(function() {
      push_field_value(this, values);
    });
    $(selector).find("tfoot > tr:last-child > td:nth-child(" + column + ")").text(format_number(sum_array(values)));
  }

  self.updateGrandTotal = function() {
    var values = [];
    $(selector).find("tbody > tr > td:last-child").each(function() {
      push_text_value(this, values);
    });
    $(selector).find("tfoot td.grand-total").text(format_number(sum_array(values)));
  }

  self.valueChanged = function(evt) {
    var col = $(this).closest("td").index() + 1;
    var row = $(this).parent().closest("tr").index() + 1;
    var v = $(this).val();
    if(v !== "") {
      v = Number(v);
      if(isNaN(v)) {
        v = "";
      } else {
        v = Math.abs(parseInt(v));
      }
      $(this).val(v);
    }
    self.updateRowTotal(row);
    self.updateColumnTotal(col);
    self.updateGrandTotal();
  }

  self.initialise = function() {
    // hook up change notifiers so that we can update totals
    $(selector).find("input.funding-value").on("change", self.valueChanged)
    // make hidden-totals visible
    $(selector).removeClass("hidden-totals");

    $(selector).parent().append("<input type='hidden' name='js_enabled' value='1'/>");
  }

  function push_field_value(elem, ary) {
    var v = $(elem).find("input[type=number]");
    if(v.length === 1) {
      var n = Number(v.val());
      if(!isNaN(n)) {
        ary.push(n);
      }
    }
  }

  function push_text_value(elem, ary) {
    var v = $(elem).text();
    v = v.replace(/,/g, "");
    var n = Number(v);
    if(!isNaN(n)) {
      ary.push(n);
    }
  }

  function sum_array(values) {
    return values.reduce(function(a, b) { return a + b; }, 0);
  }

  // toLocaleString is inconsistent across browsers, which is a shame
  // so we'll roll our own simple formatter for our values
  function format_number(n) {
      return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }
}

$(function() {
  var funding_values_table = new FundingValuesTable("table.funding-table");
  funding_values_table.initialise();
  funding_values_table.updateTotals();
});
