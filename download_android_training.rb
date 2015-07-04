require './website_downloader'

options = {
  website_url: 'http://www.androidcommunitydocs.com',
  limit_url: '/training',
  index_url: '/training/index.html',
  export_dir: './Android Training'
}

downloader = WebsiteDownloader.new(options)
downloader.start

