require 'net/http'

class ElementsController < ApplicationController
	@error_message  = ''
	def index
		@webs = Web.all
	end

	def destroy
	  	Web.destroy_all	 
	  	redirect_to elements_index_path
	end

	def a
		url = params[:url]
		return error("url no valid: #{url}") if !valid?(url)
			
		@web = Web.new(url: url)
		#Check cache
		@web.cache
		if !@web.cache?
			#dowload HTML
			@web.get_content!
			return error(@web.errors.full_messages[0]) if (!@web.errors.empty?)
			#check web content: possible javascript redirection
			js_redirect = @web.html.match(/.*window.location="[^A-Za-z0-9\/]*([^"]*)"/)
			if js_redirect
				#set absolute URL
				uri = @web.redirect || @web.url
				if js_redirect[1].match(/^(?!http:\/\/|https:\/\/|www.).*/)
					js_redirect = "#{uri}#{js_redirect[1]}" 
				else 
					js_redirect = js_redirect[1]
				end
				return error("url no valid: #{url}") if !valid?(js_redirect)
				#update web url
				@web.url = js_redirect
				@web.get_content!
				return error(@web.errors.full_messages[0]) if (!@web.errors.empty?)
			end
			#store web in cache
			@web.save
		end
		#parse html to get field href of 'a' tags
		hrefs = @web.html.scan(/<a\s+(?:[^>]*?\s+)?href="([^"]*)"/)
			
		#set absolute URL
		uri = @web.redirect || @web.url
		hrefs.map! do |href|
			if href[0].match(/^(?!http:\/\/|https:\/\/|www.).*/)
				href = "#{uri}#{href[0]}" 
			else 
				href = href[0]
			end
		end
		@result = hrefs
	end

	def img
		url = params[:url]
		#TODO validate url parameter
		return error("url no valid: #{url}") if !valid?(url)
			
		@web = Web.new(url: url)
		#Check cache
		@web.cache
		if !@web.cache?
			#dowload HTML
			@web.get_content!
			return error(@web.errors.full_messages[0]) if (!@web.errors.empty?)
			#check web content: possible javascript redirection
			js_redirect = @web.html.match(/.*window.location="[^A-Za-z0-9\/]*([^"]*)"/)
			if js_redirect
				#set absolute URL
				uri = @web.redirect || @web.url
				if js_redirect[1].match(/^(?!http:\/\/|https:\/\/|www.).*/)
					js_redirect = "#{uri}#{js_redirect[1]}" 
				else 
					js_redirect = js_redirect[1]
				end
				return error("url no valid: #{url}") if !valid?(js_redirect)
				#update web url
				@web.url = js_redirect
				@web.get_content!
				return error(@web.errors.full_messages[0]) if (!@web.errors.empty?)
			end
			#store web in cache
			@web.save
		end
		#parse html to get field src of 'img' tags
		imgs = @web.html.scan(/<img\s+(?:[^>]*?\s+)?src="([^"]*)"/)

		#set absolute URL
		uri = @web.redirect || @web.url
		imgs.map! do |img|
		 	if img[0].match(/^(?!http:\/\/|https:\/\/|www.).*/)
			  # img = "#{uri}#{img[0]}" 
			  img = img[0]
			else img = img[0]
			end
		end
		@result = imgs
	end

	private def valid?(url)
		uri = URI.parse(url)
		uri.kind_of?(URI::HTTP)
		rescue URI::InvalidURIError
		  false
	end

	private def error(text)
		flash[:error] = "#{text}"
		redirect_to elements_index_path  and return true
	
	end

end