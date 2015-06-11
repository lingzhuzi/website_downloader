require './website_downloader'

options = {
  website_url: 'http://guides.ruby-china.org',
  limit_url: '/',
  index_url: '/index.html',
  export_dir: './Guides_Ruby_China',
  selectors: {link: {selector: '#mainCol a', attr: 'href'} }
}

downloader = WebsiteDownloader.new(options)
downloader.start