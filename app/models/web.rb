class Web < ActiveRecord::Base
	validates :url, :format => URI::regexp(%w(http https))
	attr_accessor :cached, :redirects

	def initialize(attributes = {})
		super
		self.cached = false
	end

	def cache
		web = Web.find_by(url: self.url)
		if !web.nil?
			self.html = web.html
			self.cached = true
			self.redirect = web.redirect
		end
		self.cached
	end
	def cache?
		self.cached
	end
	#download and set the html, from uri
	def get_content!(uri = URI(self.url), request_max = 5)
		raise "Max number of redirects reached" if request_max <= 0
		self.redirect = uri.to_s if uri.to_s != self.url
		#TODO https ...
		begin
			response = Net::HTTP.get_response(uri)
	  	rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
		       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, Exception => e
		  self.errors.add(:url, "error GET #{self.url}: #{e}")
		  return  
		end

		case response
		when Net::HTTPSuccess then
		  #encoding in web encode (UTF-8, ISO...), UTF-8 by default
		  content_type = response['content-type'].match(/charset=([^"]*)/)
		  encoding =  content_type ? content_type[1] : 'UTF-8'
		  response.body.force_encoding(encoding)
		  self.html = response.body

		when Net::HTTPRedirection then
			get_content!(URI(response['location']), request_max - 1)

		else
		  raise  "error GET: #{response.code}"
		end
	end
end
