require './common'

class DownloaderConfig

  def initialize(config={})
    @config = config

    raise 'No Website Url' unless @config[:website_url]
    @config[:export_dir] = './out' unless @config[:export_dir]
    @config[:limit_url]  = @config[:website_url] unless @config[:limit_url]
    @config[:index_url]  = @config[:website_url] unless @config[:index_url]
    @config[:limit_url]  = DownloaderCommon.complete_url(@config[:website_url], @config[:limit_url])
    @config[:index_url]  = DownloaderCommon.complete_url(@config[:website_url], @config[:index_url])
    @config[:selectors]  = default_selectors.merge(@config[:selectors] || {})

    [:website_url, :limit_url, :index_url].each do |key|
      value = @config[key]
      value[-1] = '' if value.end_with?('/')
      @config[key] = value
    end
  end

  def [](key)
    @config[key]
  end

  private
  def default_selectors
    options = {}
    options[:link]   = {selector: 'a',      attr: 'href'}
    options[:css]    = {selector: 'link',   attr: 'href'}
    options[:js]     = {selector: 'script', attr: 'src'}
    options[:img]    = {selector: 'img',    attr: 'src'}
    options[:video]  = {selector: 'video',  attr: 'poster'}
    options[:source] = {selector: 'source', attr: 'src'}

    options
  end
end