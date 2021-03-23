class ContentItemSyncer
  def sync(flow_presenters)
    flow_presenters.each do |smart_answer|
      start_page_content_item = StartPageContentItem.new(smart_answer)
      GdsApi.publishing_api.put_content(start_page_content_item.content_id, start_page_content_item.payload)
      GdsApi.publishing_api.publish(start_page_content_item.content_id) if smart_answer.publish?

      flow_content_item = FlowContentItem.new(smart_answer)
      GdsApi.publishing_api.put_content(flow_content_item.content_id, flow_content_item.payload)
      GdsApi.publishing_api.publish(flow_content_item.content_id) if smart_answer.publish?

      new_prefix_content_item = FlowContentItem.new(smart_answer, "/#{smart_answer.name}/flow")
      GdsApi.publishing_api.put_content(
        new_prefix_content_item.content_id,
        new_prefix_content_item.payload,
      )
      GdsApi.publishing_api.publish(new_prefix_content_item.content_id) if smart_answer.publish?
    end
  end
end
