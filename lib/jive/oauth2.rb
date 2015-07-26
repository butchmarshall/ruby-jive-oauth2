require "jive/oauth2/version"
require "json"
require "ostruct"
require "base64"
require "uri"
require "net/http"
require "cgi"
require "cgi/query_string"

module Jive
	class OAuth2
		# Initialize
		#
		def initialize(options)
			@options = ::OpenStruct.new(options)

			# Require
			# - clientOAuth2CallbackUrl
			# - oauth2ConsumerKey
			# - oauth2ConsumerSecret
		end

		def get_oauth2_conf
			@options.to_h
		end

		def build_authorize_url_response_map(oauth2_conf, callback, context, extra_auth_params = {})
			state_to_encode = {
				:jiveRedirectUrl => callback
			}

			if (context)
				state_to_encode = state_to_encode.merge(context);
			end

			redirect_uri = oauth2_conf[:clientOAuth2CallbackUrl]

			query_params = {
				:redirect_uri => redirect_uri,
				:client_id => oauth2_conf[:oauth2ConsumerKey],
				:response_type => "code",
			};

			if !oauth2_conf[:oauth2Scope].nil?
				query_params[:scope] = oauth2_conf[:oauth2Scope]
			end

			if extra_auth_params.is_a?(Hash)
				query_params = query_params.merge(extra_auth_params);
			end

			state = ::Base64.encode64(state_to_encode.to_json.to_json)

			uri = URI.parse(oauth2_conf[:originServerAuthorizationUrl])

			if uri.query
				::CGI.parse(uri.query)
			end

			return {
				:url => "#{uri.scheme}://#{uri.host}#{uri.path}?state=#{state}&#{::CGI::QueryString.param(query_params)}"
			}
		end
		
		def build_oauth2_callback_object(oauth2_conf, code, extra_params = {})
			redirect_uri = oauth2_conf[:clientOAuth2CallbackUrl]
			
			post_object = {
					:grant_type => 'authorization_code',
					:redirect_uri => redirect_uri,
					:client_id => oauth2_conf[:oauth2ConsumerKey],
					:client_secret => oauth2_conf[:oauth2ConsumerSecret],
					:code => code,
			};

			if extra_params.is_a?(Hash)
				post_object = post_object.merge(extra_params)
			end

			return post_object
		end

		def get_oauth2_token(oauth2_conf, post_object)
			uri = URI(oauth2_conf[:originServerTokenRequestUrl])
			req = Net::HTTP::Post.new(uri.path)
			req.set_form_data(post_object)
			req['Content-Type'] = 'application/x-www-form-urlencoded'

			res = Net::HTTP.start(uri.hostname, uri.port) do |http|
				http.request(req)
			end

			case res
				when Net::HTTPSuccess, Net::HTTPRedirection
			# OK
			else
				res.value
			end
		end
	end
end
