require "rails_helper"

RSpec.describe "managing routes", type: :request do
  let!(:user) { create(:user) } # rubocop:disable RSpec/LetSetup

  describe "fetching details of a route" do
    before do
      FactoryBot.create(:backend, backend_id: "a-backend")
      FactoryBot.create(:backend_route, incoming_path: "/foo/bar", route_type: "exact", backend_id: "a-backend")
    end

    it "returns details of the route in JSON format" do
      get "/routes", params: { incoming_path: "/foo/bar" }

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "a-backend",
        "disabled" => false,
      )
    end

    it "404S for non-existent routes" do
      get "/routes", params: { incoming_path: "/foo" }
      expect(response.code.to_i).to eq(404)
    end
  end

  describe "creating a route" do
    before do
      FactoryBot.create(:backend, backend_id: "a-backend")
    end

    it "creates a route" do
      put_json "/routes", route: { incoming_path: "/foo/bar", route_type: "prefix", handler: "backend", backend_id: "a-backend" }

      expect(response.code.to_i).to eq(201)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "a-backend",
        "disabled" => false,
      )

      route = Route.backend.where(incoming_path: "/foo/bar").first
      expect(route).to be_truthy
      expect(route.route_type).to eq("prefix")
      expect(route.backend_id).to eq("a-backend")
    end

    it "returns an error if given invalid data" do
      put_json "/routes", route: { incoming_path: "/foo/bar", route_type: "prefix", handler: "backend", backend_id: "" }

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "disabled" => false,
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      )

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).not_to be_truthy
    end
  end

  describe "updating a route" do
    before do
      FactoryBot.create(:backend, backend_id: "a-backend")
      FactoryBot.create(:backend, backend_id: "another-backend")
      @route = FactoryBot.create(:backend_route, incoming_path: "/foo/bar", route_type: "prefix", backend_id: "a-backend")
    end

    it "updates the route" do
      put_json "/routes", route: { incoming_path: "/foo/bar", route_type: "exact", handler: "backend", backend_id: "another-backend" }

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "another-backend",
        "disabled" => false,
      )

      route = Route.backend.where(incoming_path: "/foo/bar").first
      expect(route).to be_truthy
      expect(route.route_type).to eq("exact")
      expect(route.backend_id).to eq("another-backend")
    end

    it "returns an error if given invalid data" do
      put_json "/routes", route: { :incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", "backend_id" => "" }

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "disabled" => false,
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      )

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).to be_truthy
      expect(route.backend_id).to eq("a-backend")
    end

    it "returns a 400 when given bad JSON" do
      put "/routes", params: "i'm not json", headers: { "CONTENT_TYPE" => "application/json" }
      expect(response.status).to eq(400)

      put "/routes", params: "", headers: { "CONTENT_TYPE" => "application/json" }
      expect(response.code.to_i).to eq(400)
    end
  end

  describe "deleting a route" do
    before do
      FactoryBot.create(:backend, backend_id: "a-backend")
      FactoryBot.create(:backend_route, incoming_path: "/foo/bar", route_type: "exact", backend_id: "a-backend")
    end

    it "deletes the route" do
      delete "/routes", params: { incoming_path: "/foo/bar", hard_delete: "true" }

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "a-backend",
        "disabled" => false,
      )

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).not_to be_truthy
    end

    it "returns 404 for non-existent routes" do
      delete "/routes", params: { incoming_path: "/foo" }
      expect(response.code.to_i).to eq(404)
    end
  end
end
