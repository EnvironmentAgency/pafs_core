function MultipleElementForm(element_selector) {
  var self = this;
  var selector = element_selector;
  var element_template = $(selector).find('.form-group').first().clone();
  var delete_button = $("<a href='#' class='column-one-half delete_button'>Remove contributor</a>");

  self.addElement = function(evt) {
    var new_element = element_template.clone();
    var new_delete_button = delete_button.clone();

    evt.preventDefault();

    new_element.find('input[type="hidden"]').val('');
    new_element.find('input[type="text"]').val('');

    var element_count = $(selector).find('input[type="hidden"]').length;

    new_element.find('input[type="hidden"]').attr('name', 'name[' + element_count + '][previous]');
    new_element.find('input[type="text"]').attr('name', 'name[' + element_count + '][current]');

    new_element.append(new_delete_button);
    new_element.insertBefore($(selector).find('a.add_element').parent());
  }

  self.removeElement = function(evt) {
    evt.preventDefault();
    $(evt.target).parent().remove()
  }

  self.initialize = function () {
    var add_button = $("<a href='#' class='add_element'>Add another contributor</a>");

    $(selector).append(add_button);
    add_button.wrap('<p></p>');
    add_button.on('click', this.addElement.bind(this));

    $(selector).find('>.form-group div').each(function(index, elem) {
      $(elem).append(delete_button.clone()) 
    });

    $(selector).delegate('.delete_button', 'click', this.removeElement.bind(this));
  }
}

$(function() {
  var element_form = new MultipleElementForm("form .contributors");
  element_form.initialize();
});
