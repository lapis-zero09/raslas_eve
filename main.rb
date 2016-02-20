# coding: utf-8
require './twcon.rb'
# eveの初期化
eve=Eve.new

imgloc=YAML.load_file('./imgloc.yml')

# timelineの監視
begin
  eve.timeline.userstream{|status|
    contents=status.text
    next if(contents=~/^RT/)

    id=status.user.screen_name
    id='@' + id + ' '

    if(contents=~/@lapis_ko/)
      postmatch=$'
      if(contents=~/癒して|癒し|疲れた/)
        rep_iyashi=['癒えて', '癒えろ']
        eve.iyashi(id+rep_iyashi.sample, imgloc.sample, status.id)
      else
        postmatch.gsub!(/\s|[　]/, "")
        eve.say(id + eve.docomoru_create_dialogue(postmatch), status.id)
      end
      next
    end

    # メンション以外の名前に反応
    if(contents=~/eve|Eve|イヴ|イブ|いぶ/)&&(status.user.screen_name!='lapis_ko')
      called_name=['なに?', '呼んだ?','どうしたの?']
      eve.say(id+called_name.sample, status.id)
      next
    end

    #癒し
    if(contents=~/癒して|癒し|疲れた/)&&(status.user.screen_name!='lapis_ko')
      rep_iyashi=['癒えて', '癒えろ']
      eve.iyashi(id+rep_iyashi.sample, imgloc.sample, status.id)
      next
    end

    #zero09がつぶやいたらリプライ
    if(status.user.screen_name=='lapis_zero09')
      if(contents!~/@/)
        rep_lap=["勉強しんさい","Twitterやめんさい"]
        eve.say(id + rep_lap.sample, status.id)
      end
      next
    end
  }

rescue => e
  puts e.message
  retry
end
