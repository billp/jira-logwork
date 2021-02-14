require "rspec"
require "communication/communicator"

describe Communication do
  describe Communication::Communicator do
    before(:each) do
      conn = Faraday.new(
        url: "https://www.google.com",
        headers: { "Cookie" => "fake-cookie" }
      )
      allow_any_instance_of(Communication::Communicator).to receive(:conn).and_return(conn)

      res = Object.new
      allow(res).to receive_message_chain(:env, :url).and_return("https://tst.com/")
      allow(res).to receive(:status).and_return(200)
      allow(res).to receive(:body).and_return('{"test": "a"}')

      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(res)
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(res)
      allow_any_instance_of(Faraday::Connection).to receive(:delete).and_return(res)

      # Prevent tests to write configuration with stubs
      allow(Configuration::ConfigurationManager.instance).to receive(:create_config_dir_if_needed)
      allow(Configuration::ConfigurationManager.instance)
        .to receive(:configuration_data).and_return(
          { jira_server_url: "https://www.google.com" }
        )
    end

    describe "add_cookie_if_needed" do
      it "should add cookie" do
        communicator = Communication::Communicator.send(:new)
        communicator.send(:conn).get("/") do |req|
          communicator.add_cookie_if_needed(req)
          expect(req.headers).to include("Cookie" => "fake-cookie")
        end
      end
    end

    describe "cache_call" do
      it "should cache call" do
        yield_invoked = false

        success_block = proc { puts "b" }
        callback_block = proc { yield_invoked = true }

        communicator = Communication::Communicator.send(:new)
        communicator.cache_call("/", success_block, &callback_block)

        expect(yield_invoked).to be(true)
        expect(communicator).to have_attributes(cached_request_callback: callback_block)
        expect(communicator).to have_attributes(cached_success_callback: success_block)
      end
    end

    describe "get" do
      it "should match body" do
        communicator = Communication::Communicator.send(:new)
        json = nil
        communicator.get("/") { |res| json = res }
        expect(json).to include(test: "a")
      end
    end

    describe "post" do
      it "should match body" do
        communicator = Communication::Communicator.send(:new)
        json = nil
        communicator.post("/") { |res| json = res }
        expect(json).to include(test: "a")
      end
    end

    describe "delete" do
      it "should match body" do
        communicator = Communication::Communicator.send(:new)
        json = nil
        communicator.delete("/") { |res| json = res }
        expect(json).to include(test: "a")
      end
    end

    describe "handle_response" do
      it "should return json" do
        communicator = Communication::Communicator.send(:new)
        conn = communicator.send(:conn)
        res = conn.get("/")
        json = nil
        communicator.handle_response(res) { |body| json = body }

        expect(json).to include(test: "a")
      end

      it "should relogin" do
        res = Object.new
        allow(res).to receive_message_chain(:env, :url).and_return("https://tst.com/rest/auth")
        allow(res).to receive(:status).and_return(401)
        allow(res).to receive(:body).and_return('{"test": "a"}')
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(res)
        allow_any_instance_of(Communication::Communicator).to receive(:relogin)

        communicator = Communication::Communicator.send(:new)
        communicator.get("/")
        expect(communicator).to have_received(:relogin)
      end

      it "should return status unauthorized" do
        res = Object.new
        allow(res).to receive_message_chain(:env, :url).and_return("https://tst.com")
        allow(res).to receive(:status).and_return(401)
        allow(res).to receive(:body).and_return('{"test": "a"}')
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(res)
        allow_any_instance_of(Communication::Communicator).to receive(:relogin_performed).and_return(true)

        communicator = Communication::Communicator.send(:new)
        expect { communicator.get("/") }.to raise_error(LogworkException::NotSuccessStatusCode)
      end

      it "should return status not found (404)" do
        res = Object.new
        allow(res).to receive_message_chain(:env, :url).and_return("https://tst.com")
        allow(res).to receive(:status).and_return(404)
        allow(res).to receive(:body).and_return('{"test": "a"}')
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(res)
        allow_any_instance_of(Communication::Communicator).to receive(:relogin_performed).and_return(true)

        communicator = Communication::Communicator.send(:new)
        expect { communicator.get("/") }.to raise_error(LogworkException::APIResourceNotFound)
      end

      it "should return server error (500)" do
        res = Object.new
        allow(res).to receive_message_chain(:env, :url).and_return("https://tst.com")
        allow(res).to receive(:status).and_return(500)
        allow(res).to receive(:body).and_return('{"test": "a"}')
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(res)
        allow_any_instance_of(Communication::Communicator).to receive(:relogin_performed).and_return(true)

        communicator = Communication::Communicator.send(:new)
        expect { communicator.get("/") }.to raise_error(LogworkException::NotSuccessStatusCode)
      end
    end

    describe "parse_json" do
      it "should parse json" do
        communicator = Communication::Communicator.send(:new)
        expect(communicator).to receive(:parse_json).with("{}").and_return({})
        expect(communicator).to receive(:parse_json).with('{"test": "b"}').and_return({ test: "b" })
        communicator.parse_json("{}")
        communicator.parse_json('{"test": "b"}')
      end
    end

    describe "update_cookie_header" do
      it "should update cookie header" do
        communicator = Communication::Communicator.send(:new)
        communicator.update_cookie_header("Testtt")
        conn = communicator.send(:conn)
        expect(conn.headers).to include(Cookie: "Testtt")
      end
    end
  end
end
