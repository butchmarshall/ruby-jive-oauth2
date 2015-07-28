require "jive/oauth2/version"
require "json"
require "ostruct"
require "base64"
require "uri"
require "net/http"
require "cgi"
require "cgi/query_string"

module Jive
	module OAuth2
		module_function

		# Builds an authorize url
		#
		# TODO - detailed description
		#
		# * *Args*    :
		#   - +options+ -> options
		#   - +callback+ -> callback
		#   - +context+ -> context
		#   - +extra_auth_params+ -> extra_auth_params
		# * *Returns* :
		#   - url
		# * *Raises* :
		#   - +ArgumentError+ -> if not right
		#
		def build_authorize_url_response_map(options, callback, context, extra_auth_params = {})
			oauth2_conf = ::OpenStruct.new(options).to_h

			state_to_encode = {
				:jiveRedirectUrl => callback,
				:client_id => oauth2_conf[:oauth2ConsumerKey]
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

		# Builds a callback object
		#
		# TODO - detailed description
		#
		# * *Args*    :
		#   - +options+ -> options
		#   - +code+ -> code
		#   - +extra_params+ -> extra_params
		# * *Returns* :
		#   - callback object
		# * *Raises* :
		#   - +ArgumentError+ -> if not right
		#
		def build_oauth2_callback_object(options, code, extra_params = {})
			oauth2_conf = ::OpenStruct.new(options).to_h

			redirect_uri = oauth2_conf[:clientOAuth2CallbackUrl]

			post_object = {
					:grant_type => 'authorization_code',
					:redirect_uri => redirect_uri,
					:client_id => oauth2_conf[:oauth2ConsumerKey],
					:client_secret => oauth2_conf[:oauth2ConsumerSecret],
					:code => code,
			};

			if !oauth2_conf[:oauth2CallbackExtraParams].nil?
				post_object = post_object.merge oauth2_conf[:oauth2CallbackExtraParams]
			end

			if extra_params.is_a?(Hash)
				post_object = post_object.merge(extra_params)
			end

			return post_object
		end

		# Retrieves oauth token from server
		#
		# TODO - detailed description
		#
		# * *Args*    :
		#   - +options+ -> options
		#   - +post_object+ -> post_object
		# * *Returns* :
		#   - oauth token response
		# * *Raises* :
		#   - +ArgumentError+ -> if not right
		#
		def get_oauth2_token(options, post_object)
			oauth2_conf = ::OpenStruct.new(options).to_h

			uri = URI(oauth2_conf[:originServerTokenRequestUrl])
			req = Net::HTTP::Post.new(uri.path)
			req.set_form_data(post_object)
			req['Content-Type'] = 'application/x-www-form-urlencoded'

			res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => (uri.scheme == 'https')) do |http|
				http.request(req)
			end

			case res
				when Net::HTTPSuccess, Net::HTTPRedirection
					res.body
				else
					res.value
			end
		end
	end
end
