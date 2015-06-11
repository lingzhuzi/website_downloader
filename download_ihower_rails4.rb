require './website_downloader'

options = {
  website_url: 'https://ihower.tw',
  limit_url: '/rails4',
  index_url: '/rails4/index.html',
  export_dir: './Ruby on Rails 实战圣经'
}

downloader = WebsiteDownloader.new(options)
downloader.start