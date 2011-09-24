require "net/http"
require "net/https"
require 'json'

API_KEY = "7a649f5ef8190ea055e9a01ca227303a:19:64897553"
API_HOST = "api.nytimes.com"

module NyTimes
  extend self
  def self.news_wire(section = "all", offset = 0)
    request = "/svc/news/v3/content/all/#{section}/170.json?offset=#{offset}&api-key=#{API_KEY}"
    code, response = get(request)
    articles = []
    if code.to_i == 200
      news_js = JSON.parse(response)
      copyright = news_js['copyright']
      status = news_js['status']
      num_results = news_js['num_results']
      results = news_js['results']
      results.each do |article|
        # "section":"U.S.",
        # "title":"Weather Aids Crews in Oil Spill Cleanup Efforts ",
        # "abstract":"Calm in the Gulf of Mexico let crews step up multiple 
        #   efforts to contain the crude oil leaking uncontrollably and spreading 
        #   toward the coasts of four states.",
        # "url":"http:\/\/www.nytimes.com\/2010\/05\/05\/us\/05spill.html",
        # "byline":"By IAN URBINA, JUSTIN GILLIS and LIZ ROBBINS"
        image = nil
        multimedia = nil
        if (article['multimedia'].size > 0)
          multimedia = article['multimedia'].first
        end
        if (multimedia != nil) && (multimedia['type'] == "image")
          image = Hash.new
          image['url'] = multimedia['url']
          image['height'] = multimedia['height']
          image['width'] = multimedia['width']
        end
        articles << {"section" => article['section'], "title" => article['title'],
          "abstract" => article['abstract'], "url" => article['url'],
          "byline" => article['byline'].downcase.capitalize,
          "section" => article['section'],
          "image" => image}
      end
    end
    return articles
  end

  def self.sections_list
    #  http://api.nytimes.com/svc/news/v3/content/section-list[.reponse-format]?api-key={your-API-key}
    request = "/svc/news/v3/content/all/#{section}/170.json?api-key=#{API_KEY}"
    code, response = get(request)
    sections = []
    if code.to_i == 200
      sections_json = JSON.parse(response)
    end
  end

  private
  def get(request)
    http_r = Net::HTTP.new(API_HOST)
    http_r.use_ssl = false
    response = nil
    begin
      http_r.start() do |http|
        req = Net::HTTP::Get.new(request)
        response = http.request(req)
      end
      return [response.code, response.body]
    rescue Errno::ECONNREFUSED
      return [503, "unavailable"]
    rescue SocketError
      return [503, "unavailable"]
    end
  end
end
