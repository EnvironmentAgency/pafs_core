# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  module ApplicationHelper
    # for our form builder
    def pafs_form_for(name, *args, &block)
      options = args.extract_options!

      content_tag(:div,
                  form_for(name,
                           *(args << options.merge(builder: PafsCore::FormBuilder)),
                           &block),
                  class: "pafs_form")
    end

    def make_page_title(title)
      "#{title} - #{t(:global_proposition_header)} - GOV.UK"
    end

    # we're not including Devise in the engine so the current_user
    # will not be available unless brought in via the application using this
    # engine (might not even be current_user ...)
    def current_resource
      resource = nil
      if Object.const_defined?("Devise")
        Devise.mappings.values.each do |m|
          resource = send("current_#{m.name}") if send("#{m.name}_signed_in?")
        end
      end
      resource
    end

    # Sortable columns helper method: this one just takes the current sort order (asc or desc) and
    # returns the appropriate html entity code for the arrow to display.
    def get_arrow(curr_sort_order)
      arrow = if curr_sort_order == "desc"
                "&#9660;"
              else
                "&#9650;" # default is ascending which is the up arrow.
              end
    end

    # Sortable columns helper method: this one works out the sort properties to
    # associate with the column, specifically the next sort order and
    # the sort order denoting arrow to display on the page.
    # The next sort order to associate with this column (this_col),
    # is worked out assuming that:
    # 1 the default sort order for a currently unsorted column should be ascending
    # 2 if this column is the currently sorted column then the sort order should be reversed
    # (this is intended to support usage where-by a user inverts the sort order of a column
    # by re-clicking on a link)
    # 3 If no columns are currently sorted but this column is the default sort column
    # then the column should have the same sort properties as if it was the currently sorted column
    # It also works out the arrow to display assuming that:
    # 1 The arrow denotes the current sort order.
    # 2 The arrow points up for asc, meaning smallest values first.
    # 3 The arrow points down for desc, meaning smallest values last.
    # 4 If a column is not the currently sorted column (or the default sortable column if
    # no other columns are sorted) then no arrow should be displayed at all.
    def get_next_sort_order_and_curr_arrow(current_sorted_col, this_col, curr_sort_order,
                                           default_sort_col, default_sort_order)
      # Assuming that, if no user-defined sorts have yet been run, the system has already applied
      # any default sort properties.

      if current_sorted_col.nil? \
      && !default_sort_col.nil? && default_sort_col == this_col
        current_sorted_col = this_col
        curr_sort_order = default_sort_order
      end

      curr_sort_order = "asc" if curr_sort_order.nil?
      if current_sorted_col == this_col
        # NB what's going to be written to the link is the next sort order,
        # which is the inverse of the current sort order
        arrow = get_arrow(curr_sort_order)
        next_sort_order = if curr_sort_order == "asc"
                            "desc"
                          else
                            "asc" # Default sort order is ascending
                          end
      else
        arrow = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" # Not the currently sorted column, so display no arrow.
        next_sort_order = "asc" # Starting sort order should be asc
      end
      sort_properties_for_col = { next_sort_order: next_sort_order, curr_arrow: arrow }
      sort_properties_for_col
    end
  end
end
