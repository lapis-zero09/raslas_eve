# coding: utf-8
require './twcon.rb'
# eveの初期化
eve=Eve.new


reply=YAML.load_file('./reply.yml')
imgloc=YAML.load_file('./imgloc.yml')

# timelineの監視
begin
  eve.timeline.userstream{|status|
    contents=status.text
    next if(contents=~/^RT/)

    id=status.user.screen_name
    id='@' + id + ' '

    if(contents=~/@lapis_ko/)
      if(contents=~/癒して|癒し|疲れた/)
        rep_iyashi=['癒えて', '癒えろ']
        eve.iyashi(id+rep_iyashi.sample, imgloc.sample, status.id)
      else
        word = reply.sample
        eve.say(id + word, status.id)
      end
      next
    end

    # メンション以外の名前に反応
    if(contents=~/eve|Eve|イヴ|いぶ/)&&(status.user.screen_name!='_eve')
      called_name=['なに?', '呼んだ?','どうしたの?']
      eve.say(id+called_name.sample, status.id)
      next
    end

    #癒し
    if(contents=~/癒して|癒し|疲れた/)&&(status.user.screen_name!='_eve')
      rep_iyashi=['癒えて', '癒えろ']
      eve.iyashi(id+rep_iyashi.sample, imgloc.sample, status.id)
      next
    end

    #zero09がつぶやいたらリプライ
    if(status.user.screen_name=='lapis_zero09')
      rep_lap=["勉強しんさい","Twitterやめんさい"]
      eve.say(id + rep_lap.sample, status.id)
      next
    end
  }

rescue => e
  puts e.message
  retry
end
