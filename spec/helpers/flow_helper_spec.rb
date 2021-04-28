RSpec.describe FlowHelper do
  describe "#flow" do
    it "returns the flow for the current request" do
      params[:id] = "flow-name"

      flow = SmartAnswer::Flow.new { name "flow-name" }
      flow_registry = instance_double("SmartAnswer::FlowRegistry")
      allow(SmartAnswer::FlowRegistry).to receive(:instance).and_return(flow_registry)
      allow(flow_registry).to receive(:find).with("flow-name").and_return(flow)

      expect(helper.flow).to be(flow)
    end
  end

  describe "#response_store" do
    context "for session based flow" do
      it "returns a session response store with flow name and session" do
        params[:id] = "flow-name"

        store = double("response-store")

        flow = SmartAnswer::Flow.new { response_store :session }
        allow(helper).to receive(:flow).and_return(flow)

        expect(SessionResponseStore).to receive(:new).with(
          flow_name: params[:id], session: session,
        ).and_return(store)

        expect(helper.response_store).to be(store)
      end
    end

    context "for non-session based flow" do
      it "returns a response store" do
        store = double("response-store")
        controller.request.query_parameters["question1"] = "response1"
        controller.request.query_parameters["key"] = "value"

        flow = SmartAnswer::Flow.new do
          response_store :other
          radio :question1
        end

        allow(helper).to receive(:flow).and_return(flow)

        expect(ResponseStore).to receive(:new).with(
          responses: { "question1" => "response1" },
        ).and_return(store)

        expect(helper.response_store).to be(store)
      end
    end
  end

  describe "#content_item" do
    it "returns a content item for the flow" do
      flow = SmartAnswer::Flow.new { name "flow-name" }
      allow(helper).to receive(:flow).and_return(flow)

      content_item = { "content_item": "value" }
      allow(ContentItemRetriever).to receive(:fetch).with("flow-name")
        .and_return(content_item)

      expect(helper.content_item).to be(content_item)
    end
  end
end
