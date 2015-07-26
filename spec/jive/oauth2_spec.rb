require 'spec_helper'

describe Jive::OAuth2 do
	it 'has a version number' do
		expect(Jive::OAuth2::VERSION).not_to be nil
	end
	
	it 'does get_oauth2_conf' do
		oauth = Jive::OAuth2.new(
			"clientOAuth2CallbackUrl" => "http://myserver.com/api/v1/jive/oauth/oauth2Callback.json",
			"oauth2ConsumerKey" => "o8zs1rikbnad2cjtl7augi8sdjpwn3o8.i",
			"oauth2ConsumerSecret" => "a3t3g60lwf7ri0znuguffejzqwhh41wo.s",
			"originServerAuthorizationUrl" => "http://sandbox.jiveon.com/oauth2/authorize",
			"originServerTokenRequestUrl" => "http://sandbox.jiveon.com/oauth2/token",
			"oauth2CallbackExtraParams" => nil,
		)
		oauth2_conf = oauth.get_oauth2_conf().to_h
		
		expect(oauth2_conf).to eq({
			:clientOAuth2CallbackUrl => "http://myserver.com/api/v1/jive/oauth/oauth2Callback.json",
			:oauth2ConsumerKey => "o8zs1rikbnad2cjtl7augi8sdjpwn3o8.i",
			:oauth2ConsumerSecret => "a3t3g60lwf7ri0znuguffejzqwhh41wo.s",
			:originServerAuthorizationUrl => "http://sandbox.jiveon.com/oauth2/authorize",
			:originServerTokenRequestUrl => "http://sandbox.jiveon.com/oauth2/token",
			:oauth2CallbackExtraParams => nil
		})
	end

	it 'does build_authorize_url_response_map' do
		oauth = Jive::OAuth2.new(
			"clientOAuth2CallbackUrl" => "http://myserver.com/api/v1/jive/oauth/oauth2Callback.json",
			"oauth2ConsumerKey" => "o8zs1rikbnad2cjtl7augi8sdjpwn3o8.i",
			"oauth2ConsumerSecret" => "a3t3g60lwf7ri0znuguffejzqwhh41wo.s",
			"originServerAuthorizationUrl" => "http://sandbox.jiveon.com/oauth2/authorize",
			"originServerTokenRequestUrl" => "http://sandbox.jiveon.com/oauth2/token",
			"oauth2CallbackExtraParams" => nil,
		)

		oauth2_conf = oauth.get_oauth2_conf().to_h
		callback = "http://sandbox.jiveon.com/gadgets/jiveOAuth2Callback";
		context = {
			:viewerID => "3398A8F4FE0E8C1F1785AC0D546F1506CB3C7D69",
			:context => {
				:jiveTenantID => '76406c34-5df8-432f-a869-59192cacdafd-dev',
				:originJiveTenantID => '76406c34-5df8-432f-a869-59192cacdafd-dev',
			}
		}
		extraAuthParams = {}

		response_map = oauth.build_authorize_url_response_map(oauth2_conf, callback, context, extraAuthParams)

		expect(response_map).to eq({
			:url => "http://sandbox.jiveon.com/oauth2/authorize?state=IntcImppdmVSZWRpcmVjdFVybFwiOlwiaHR0cDovL3NhbmRib3guaml2ZW9u\nLmNvbS9nYWRnZXRzL2ppdmVPQXV0aDJDYWxsYmFja1wiLFwidmlld2VySURc\nIjpcIjMzOThBOEY0RkUwRThDMUYxNzg1QUMwRDU0NkYxNTA2Q0IzQzdENjlc\nIixcImNvbnRleHRcIjp7XCJqaXZlVGVuYW50SURcIjpcIjc2NDA2YzM0LTVk\nZjgtNDMyZi1hODY5LTU5MTkyY2FjZGFmZC1kZXZcIixcIm9yaWdpbkppdmVU\nZW5hbnRJRFwiOlwiNzY0MDZjMzQtNWRmOC00MzJmLWE4NjktNTkxOTJjYWNk\nYWZkLWRldlwifX0i\n&redirect_uri=http%3A%2F%2Fmyserver.com%2Fapi%2Fv1%2Fjive%2Foauth%2Foauth2Callback.json&client_id=o8zs1rikbnad2cjtl7augi8sdjpwn3o8.i&response_type=code"
		})
	end
end
