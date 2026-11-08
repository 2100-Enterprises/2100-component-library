module ComponentLibrary2100
  # <%= ui_table_header "Name" %>                  <%# <th scope="col">Name</th> %>
  # <%= ui_table_header "Ada", scope: :row %>      <%# <th scope="row">Ada</th> %>
  #
  # A table header cell that always carries a `scope`, so screen readers can tie each data cell
  # to its headings. `scope:` is `:col` (default), `:row`, `:colgroup` or `:rowgroup`. Pair it
  # with TableComponent; for a sortable column heading use `ui_sort_header`. HTML attributes
  # go on the <th>.
  class TableHeaderComponent < BaseComponent
    SCOPES = %i[col row colgroup rowgroup].freeze

    def initialize(scope: :col, **html_options)
      super(**html_options)
      @scope = scope.to_sym
      raise ArgumentError, "Unknown scope: #{scope.inspect} (use #{SCOPES.map(&:inspect).join(", ")})" unless SCOPES.include?(@scope)
    end

    def call
      tag.th(content, **attrs(nil, scope: @scope))
    end
  end
end
