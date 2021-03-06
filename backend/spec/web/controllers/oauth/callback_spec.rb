require "spec_helper"

describe Web::Controllers::Oauth::Callback do
  let(:params) do
    {
      code: "abc123",
    }
  end

  let(:authorize_url) { "http://fake.example.com/oauth/authorize" }
  let(:auth_code) { double(OAuth2::Strategy::AuthCode) }
  let(:client) { double(OAuth2::Client, auth_code: auth_code) }
  let(:github_user) { double(login: "radar", name: "Ryan Bigg") }
  let(:github_emails) do
    [
      {
        primary: false,
        email: "non-primary@example.com"
      },
      {
        primary: true,
        email: "primary@example.com"
      },
    ]
  end
  let(:github_client) { double(Octokit::Client, user: github_user, emails: github_emails) }
  let(:user_repo) { double(UserRepository) }
  let(:session) do
    {
      state: "state-abc123"
    }
  end

  subject do
    described_class.new(
      user_repo: user_repo
    )
  end

  before do
    allow(subject).to receive(:session) { session }
    allow(subject).to receive(:client) { client }
  end

  context "when fetching the token is successful" do
    before do
      expect(auth_code).to receive(:get_token).with(
        "abc123",
        redirect_uri: ENV.fetch("FRONTEND_URL") + "/oauth/callback",
        state: "state-abc123"
      ).and_return("token-123abc")
      allow(subject).to receive(:build_github_client) { github_client }
    end

    context "when a user is already known" do
      let(:user) { double(User, email: "me@ryanbigg.com") }

      before do
        allow(user_repo).to receive(:find_by_github_login) { user }
      end

      it "re-uses that user" do
        expect(user_repo).not_to receive(:create)
        subject.(params)
      end
    end

    context "when the user is not known" do
      before do
        allow(user_repo).to receive(:find_by_github_login) { nil }
      end

      let(:user) { double(User, email: "me@ryanbigg.com") }

      it "creates that user" do
        expect(user_repo).to receive(:create).with(hash_including(
          email: "primary@example.com",
          name: "Ryan Bigg",
          github_login: "radar",
        )) { user }
        subject.(params)
      end

      it "returns a JWT for the client" do
        allow(user_repo).to receive(:create) { user }
        status, _, body = subject.(params)
        expect(status).to eq(200)
        jwt_token = body.first["jwt_token"]
        expect(jwt_token).not_to be_nil
      end
    end
  end

  context "when fetching the token fails" do
    before do
      error_params = {
        "error" => "bad_verification_code",
        "error_description"=>"The code passed is incorrect or expired."
      }
      expect(auth_code).to receive(:get_token) do
        double(OAuth2::AccessToken, params: error_params)
      end
    end

    it "handles failures from re-using the oauth code" do
      status, _, body = subject.(params)
      error = JSON.parse(body.first)
      expect(error["error"]).to eq("bad_verification_code")
      expect(error["error_description"]).to eq("The code passed is incorrect or expired.")
    end
  end
end
