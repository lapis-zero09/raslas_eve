# coding: utf-8
require './twcon.rb'
# eveの初期化
eve=Eve.new


reply=YAML.load_file('./reply.yml')
called_name=['なに?', '呼んだ?','どうしたの?']

# timelineの監視
begin
  eve.timeline.userstream{|status|
    contents=status.text
    next if(contents=~/^RT/)

    id=status.user.screen_name
    id='@' + id + ' '

    if(contents=~/@lapis_ko/)
      word = reply.sample
      eve.say(id + word, status.id)
      next
    end

    # メンション以外の名前に反応
    if(contents=~/eve|Eve|イヴ|いぶ/)&&(status.user.screen_name!='_eve')
      word=called_name.sample
      eve.say(id+word, status.id)
      next
    end

    # shandyがつぶやいたらリプライ
    if(status.user.screen_name=='lapis_zero09')
      replap=["勉強しんさい","Twitterやめんさい"]
      eve.say(id + replap.sample, status.id)
      next
    end
  }

rescue => e
  puts e.message
  retry
end
