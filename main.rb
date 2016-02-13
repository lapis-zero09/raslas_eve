# coding: utf-8
require './twcon.rb'

# eveの初期化
eve = Eve.new



reply = ['そうだ','へえ!','ここだよ','さよなら','そうだよ',
         '困ったね','そのとおり','お幸せに','なにかさがしてるの?',
         'まったくもってわからない','いわれてるから','うん','どうして?',
         'そうだね……','ここでなにしてるの?','きみをひとりにはしない',
         'ちゃんとしてるんだ、わたしは','どういうこと?','えっ?','むむむ',
         'こんばんは','さようなら','こんにちは','アハハハハハ','ハハハハハハ',
         'アッハッハッハッハッ','何が胎児をそうさせたか','あっ','ハッハッハッハッ',
         '……う……うん……','……………………','夢','ふーむ','ハッハッハッ',
         'ハハハハハ','ハイ','うん','いや','胎児の夢','……………',
         'いいえ','これだわ','いやどうして','そうでしょう','ところがねえ',
         'そうなるかしら','ようくわかりました','それは、またなぜにです？',
         '明察です','なるほど……','そうなんだわ','そうですか','悪いことをしたわ',
         'そうです','なるほど','冗談じゃない','ええ','ありがとう','ばかばかしいわ',
         'ごめんなさい','それで?','その次は？'
        ]

called_name = ['なに?', '呼んだ?','どうしたの?']

# timelineの監視
begin
  eve.timeline.userstream do |status|
    speak = Speak.new
    contents = status.text
    next if contents =~ /^RT/

    id = status.user.screen_name
    speak.user = id
    id = '@' + id + ' '

    speak.id = status.id
    speak.in_reply_to_status_id = status.in_reply_to_status_id
    speak.created_at = status.created_at
    speak.words = contents
    speak.save

    if contents =~ /@lapis_ko/
      word = reply.sample
      eve.say(id + word, status.id)
      next
    end

    # メンション以外の名前に反応
    if contents =~ /eve|Eve|イヴ|いぶ/ && status.user.screen_name != '_eve'
      word = called_name.sample
      eve.say(id + word, status.id)
      next
    end

    # nzwがつぶやいたらリプライ
    if status.user.screen_name == 'lapis_zero09'
      eve.say(id + reply.sample, status.id)
      next
    end
  end

rescue => e
  puts e.message
  retry
end
