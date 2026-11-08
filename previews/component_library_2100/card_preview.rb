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
  end
end
