require './website_downloader'

options = {
  website_url: 'http://www.gotealeaf.com',
  limit_url: '/books/ruby/read',
  index_url: '/books/ruby/read/introduction',
  export_dir: './Tealeaf_Academy_Ruby'
}

downloader = WebsiteDownloader.new(options)
downloader.start