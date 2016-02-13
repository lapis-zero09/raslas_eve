# coding:utf-8

require 'yaml'
require 'twitter'
require 'tweetstream'

class Eve
  # 外部から参照できるメンバ変数
  attr_accessor :client, :timeline
  def initialize
    keys = YAML.load_file('./config.yml')

    # restAPI初期化
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = keys["api_key"]
      config.consumer_secret = keys["api_secret"]
      config.access_token = keys["access_token"]
      config.access_token_secret = keys["access_token_secret"]
    end


    # StreamAPI初期化
    TweetStream.configure do |config|
      config.consumer_key = keys["api_key"]
      config.consumer_secret = keys["api_secret"]
      config.oauth_token = keys["access_token"]
      config.oauth_token_secret = keys["access_token_secret"]
      config.auth_method = :oauth
    end

    @timeline = TweetStream::Client.new
  end

  # 引数を投稿するメソッド
  def say(words, id)
    @client.update(words,:in_reply_to_status_id => id)
  end

  def alert(words)
    @client.update(words)
  end
end
