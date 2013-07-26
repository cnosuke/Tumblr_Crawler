# coding:utf-8
require "tumblr_client"
require "open-uri"
require "digest/md5"
require "pp"

#自分のTumblrで投稿した画像を全てダウンロードするクラス
class Tumblr_Crawler
  #コンストラクタ
  def initialize
    Tumblr.configure do |config|
      config.consumer_key="consumer_key"
      config.consumer_secret="consumer_secret"
      config.oauth_token="oauth_token"
      config.oauth_token_secret="oauth_token_secret"
    end 

    @client = Tumblr::Client.new
  end

  #画像をダウンロードする
  def get_photos
    max_post = @client.info["user"]["blogs"][0]["posts"] #投稿回数
    0.step(max_post,20).each do |i|
      results = @client.posts("userid.tumblr.com", :type => "photo", :limit => 20, :offset => i)
      get_urls(results).each do |url|
        save_photo(url)
      end
    end
  end

  private
  #20件のURLの配列を取得
  def get_urls(photo_data)
    return photo_data["posts"].map{ |post| post["photos"].map{ |photo| photo["original_size"]["url"] } }.flatten
  end

  #指定したURLの画像を保存
  def save_photo(url)
    filename = Digest::MD5.new.update(url) #画像のファイル名はハッシュ値
    ext = url.split(".")[-1] #拡張子
    path = "#{File.expand_path("~")}/wallpaper/" #画像を保存するディレクトリ
    begin
      open(path + filename.to_s+"."+ext,"wb") do |file|
        open(url) do |data|
          file.write(data.read)
        end
      end
    rescue => e
      puts e
    end
  end

end


tumblr = Tumblr_Crawler.new
tumblr.get_photos








