# encoding: utf-8
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'pathname'
require './config'
require './common'

class WebsiteDownloader

  JS = 1
  CSS = 2
  HTML = 3
  IMAGE = 4
  VIDEO = 5

  attr_accessor :current_page_url

  def initialize(options)
    @config = DownloaderConfig.new(options)
    @current_page_url = @config[:index_url]
    @downloaded_urls = []
    @queue = [@config[:index_url]]
  end

  def start
    while @queue.size > 0
      url = @queue.shift
      download(url) unless is_downloaded?(url)
    end
  rescue => e
    puts "error occurred when downloading #{@current_page_url}"
    puts e.message
    puts e.backtrace.join("\n")

    start
  end

  def download(url)
    case file_type(url)
    when JS, CSS
      save_asset(url)
    when IMAGE, VIDEO
      save_asset(url, true)
    when HTML
      if url.start_with?(@config[:limit_url])
        doc = get_doc(url)
        if doc
          urls = find_and_modify_urls(doc)
          save_html(url, doc)
          @queue.concat(urls)
        end
      end
    else
      puts "unkown type of file : #{url}"
    end
    @downloaded_urls << url
  end

  def get_doc(url)
    res = open_url(url)
    res ? Nokogiri::HTML(res) : nil
  end

  def open_url(url)
    puts "opening: #{url}"
    @current_page_url = url
    return open(url, :read_timeout => 60)
  rescue => e
    puts e.message
    puts "error occurred when load page: #{url}"
    puts e.backtrace.join("\n")
  end

  def file_type(url)
    url = url.downcase
    return HTML if url.include?('.jsp')
    return JS   if url.include?('.js')
    return CSS  if url.include?('.css')
    image_ext_names = ['.jpg', '.jpeg', '.gif', '.png', '.ico', '.svg', '.ttf', '.pdf']
    image_ext_names.each do |ext|
      return IMAGE if url.include?(ext)
    end
    video_ext_names = ['.mp4', '.mp3']
    video_ext_names.each do |ext|
      return VIDEO if url.include?(ext)
    end
    HTML
  end

  def is_downloaded?(url)
    url = DownloaderCommon.pure_url(url)
    @downloaded_urls.include?(url)
  end

  def find_and_modify_urls(doc)
    urls = []

    @config[:selectors].each do |_, node_set|
      links = doc.css(node_set[:selector])
      links.each do |link|
        link_url = link.attr(node_set[:attr])
        if link_url
          url = DownloaderCommon.complete_url(@current_page_url, link_url)
          if url
            pure_url = DownloaderCommon.pure_url(url)
            urls << pure_url

            modified_url = modified_url(url)

            link[node_set[:attr]] = modified_url
          end
        end
      end
    end

    urls.uniq
  end

  def modified_url(url)
    current_page_file_name = generate_file_name(@current_page_url)
    current_page_file_name = current_page_file_name.split('/')[0..-2].join('/')
    file_name = generate_file_name(url)

    return if url == ''

    current_page_path_name = Pathname.new(current_page_file_name)
    path_name = Pathname.new(file_name)

    modified_url = path_name.relative_path_from(current_page_path_name).to_s

    flag = false
    spliters = ['#', '?']
    spliters.each do |spliter|
      if modified_url.include?(spliter)
        arr = modified_url.split(spliter)
        if !([JS, CSS, IMAGE, VIDEO].include?(file_type(modified_url)))
          arr[0] = DownloaderCommon.add_html_ext(arr[0])
        end
        modified_url = arr.join(spliter)
        flag = true
        break
      end
    end

    if !flag && !([JS, CSS, IMAGE, VIDEO].include?(file_type(modified_url)))
      modified_url = DownloaderCommon.add_html_ext(modified_url)
    end

    modified_url
  end

  def find_and_modify_urls_in_css(text)
    regex = /url\(['"]?(.*?)['"]?\)/
    urls = []

    text.scan(regex).each do |match_data|
      url = match_data[0]
      complete_url = DownloaderCommon.complete_url(@current_page_url, url)
      if complete_url
        pure_url = DownloaderCommon.pure_url(complete_url)
        urls << complete_url

        modified_url = modified_url(complete_url)
        text.gsub!(url, modified_url)
      end
    end

    urls.uniq
  end

  def save_html(url, doc)
    file_name = generate_file_name(url)
    save_to_file(file_name, doc.to_html)
  end

  def save_asset(url, binary=false)
    temp_file = open_url(url)
    if temp_file
      file_name = generate_file_name(url)
      text = temp_file.read
      if file_type(url) == CSS
        urls = find_and_modify_urls_in_css(text)
        @queue.concat urls
        @queue.uniq!
      end
      save_to_file(file_name, text, binary)
      temp_file.close
    end
  end

  def save_to_file(file_name, text, binary=false)
    puts "saving : #{file_name}"
    DownloaderCommon.open_file(file_name, binary ? 'wb' : 'w') do |file|
      file.puts text
    end
    puts "saved\n"
  end

  def generate_file_name(url)
    prefixes = [@config[:website_url], 'http:/', 'https:/']
    prefixes.each do |prefix|
      return url.gsub(prefix, @config[:export_dir]) if url.start_with?(prefix)
    end

    ''
  end

end
