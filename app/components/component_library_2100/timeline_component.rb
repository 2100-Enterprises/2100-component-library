module ComponentLibrary2100
  # <%= render TimelineComponent.new(label: "Project activity", id: "activity") do |timeline| %>
  #   <% timeline.with_event(time: Time.current, title: "Proposal approved", variant: :success) { "Dana signed off." } %>
  #   <% timeline.with_event(time: Date.new(2026, 5, 3), title: "Draft shared", icon: "D") %>
  # <% end %>
  #
  # A vertical timeline or activity feed: an <ol> of events (see TimelineEventComponent for the
  # options each takes). Display only, with no JavaScript and no keyboard behaviour. `label:` gives
  # the list an aria-label (recommended). `alternate: true` puts events on alternating sides of the
  # line from md: up, and stacks them on phones.
  #
  # Live feeds: give the list an `id:` and prepend new events with Turbo Streams. Each event is a
  # self-contained <li>, and its connector and alternating side come from CSS, so a prepended
  # event needs no changes to its neighbours:
  #
  #   <%= turbo_stream.prepend "activity" do %>
  #     <%= render ComponentLibrary2100::TimelineEventComponent.new(time: Time.current, title: "File uploaded") %>
  #   <% end %>
  #
  # Meaning is never carried by colour: markers are aria-hidden, so put what happened in the
  # title or text. No outer margins.
  class TimelineComponent < BaseComponent
    LIST = "group/timeline m-0 p-0 list-none"

    renders_many :events, "ComponentLibrary2100::TimelineEventComponent"

    def initialize(label: nil, alternate: false, **html_options)
      super(**html_options)
      @label = label
      @alternate = alternate
    end

    def call
      tag.ol(safe_join(events), **attrs(LIST, aria: {label: @label}.compact, data: {alternate: (@alternate ? "" : nil)}.compact))
    end
  end
end
