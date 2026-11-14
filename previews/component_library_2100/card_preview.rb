module ComponentLibrary2100
  # @logical_path basics
  class CardPreview < BasePreview
    # @param title text
    # @param body textarea
    def playground(title: "Card title", body: "Body copy goes straight in and is wrapped in the card body.")
      template(:playground, title: title, body: body)
    end

    # `body: false` lets a ListGroup sit edge to edge.
    def flush
      template(:flush)
    end

    # `with_media` holds any top content in a fixed aspect ratio (`:video`, `:square`, `:auto` or "4/3").
    def media
      template(:media)
    end

    # `href:` and `link_label:` make the whole card a link; the Archive button opts out with `relative z-10`.
    def linked
      template(:linked)
    end
  end
end
