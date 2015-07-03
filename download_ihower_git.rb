require './website_downloader'

options = {
  website_url: 'https://ihower.tw',
  limit_url: '/git',
  index_url: '/git/index.html',
  export_dir: './Git 版本控制系统'
}

downloader = WebsiteDownloader.new(options)
downloader.start