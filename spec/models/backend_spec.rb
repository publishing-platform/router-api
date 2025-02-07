require "rails_helper"

RSpec.describe Backend, type: :model do
  describe "validations" do
    subject(:backend) { FactoryBot.build(:backend) }

    describe "on backend_id" do
      it "is required" do
        backend.backend_id = ""
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_id].size).to eq(1)
      end

      it "is a slug format" do
        backend.backend_id = "not a slug"
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_id].size).to eq(1)
      end

      it "is unique" do
        FactoryBot.create(:backend, backend_id: "a-backend")
        backend.backend_id = "a-backend"
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_id].size).to eq(1)
      end

      it "has a db level uniqueness constraint" do
        FactoryBot.create(:backend, backend_id: "a-backend")
        backend.backend_id = "a-backend"

        expect {
          backend.save validate: false
        }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe "on backend_url" do
      it "is required" do
        backend.backend_url = ""
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_url].size).to eq(1)
      end

      it "accepts an HTTP URL" do
        backend.backend_url = "http://foo.example.com/"
        expect(backend).to be_valid
      end

      it "accepts an HTTPS URL" do
        backend.backend_url = "https://foo.example.com/"
        expect(backend).to be_valid
      end

      it "rejects invalid URLs" do
        [
          "I'm not an URL",
          "ftp://example.org/foo/bar",
          "mailto:me@example.com",
          "www.example.org/foo",
          "/relative/url",
          "http://",
          "http:foo",
          "http://foo.example.com/?bar=baz",
          "http://foo.example.com/#bar",
        ].each do |url|
          backend.backend_url = url
          expect(backend).not_to be_valid
          expect(backend.errors[:backend_url].size).to eq(1)
        end
      end
    end
  end

  describe "as_json" do
    subject(:backend) { FactoryBot.build(:backend) }

    it "does not include the mongo id in its json representation" do
      expect(backend.as_json).not_to have_key("_id")
    end

    it "includes details of errors if any" do
      backend.backend_id = ""
      backend.valid?
      json_hash = backend.as_json
      expect(json_hash).to have_key("errors")
      expect(json_hash["errors"]).to eq(backend_id: ["can't be blank"])
    end

    it "does not include the errors key when there are none" do
      expect(backend.as_json).not_to have_key("errors")
    end
  end

  describe "destroying" do
    subject(:backend) { FactoryBot.create(:backend) }

    it "does not allow destroy when it has associated routes" do
      FactoryBot.create(:backend_route, backend_id: backend.backend_id)

      expect { backend.destroy }.not_to(change(described_class, :count))
    end

    it "allows destroy otherwise" do
      backend2 = FactoryBot.create(:backend)
      FactoryBot.create(:backend_route, backend_id: backend2.backend_id)

      backend.destroy!

      expect(described_class.count).to eq 1
    end
  end
end
