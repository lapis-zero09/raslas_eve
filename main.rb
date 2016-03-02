# coding: utf-8
require './twcon.rb'
require './r-recipe.rb'
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

    # reply_answer
    if(contents=~/@lapis_ko/)&&(status.user.screen_name!='lapis_ko')
      postmatch=$'

      #eve_help
      if(contents=~/help|ヘルプ|へるぷ|Help|HELP|man|-h|-help|manual/)
        help=id+"\n・5W1Hに対して質問に答えるよ!\n・癒し|疲れた に対して\"Iyashi\"を提供するよ!\n・飯|お腹すいた に対して料理のレシピを提供するよ!\n詳しくはここ(https://github.com/Shandy-ko/raslas_eve)"
        eve.say(help, status.id)

      # 癒し
      elsif(contents=~/癒し|疲れた/)
        rep_iyashi=['癒えて', '癒えろ']
        eve.iyashi(id+rep_iyashi.sample, imgloc.sample, status.id)

      # 料理推薦
      elsif(contents=~/飯/)
        food=RecommendRecipe.new
        if(contents=~/:|：/)
          eve.say(id+food.call("#{$'}"), status.id)
        else
          eve.say(id+"ご飯にする？\n"+food.call("なんでもいい")+"食べたいものがあれば「ご飯:食べたいもの」で指定してね！", status.id)
        end

      # 会話
      else
        postmatch.gsub!(/\s|[　]|\?|\？/, "")
        # QandA
        if(postmatch=~/誰|何処|だれ|どこ|何時|いつ|どうやって|どうして|何故|なぜ|どの|何|なに|どれ|は$/)
          eve.say(id+eve.docomoru_create_knowledge(postmatch), status.id)
        # 会話
        else
          eve.say(id+eve.docomoru_create_dialogue(postmatch), status.id)
        end

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

    # 料理推薦
    if(contents=~/飯|お腹すいた/)&&(status.user.screen_name!='lapis_ko')
      food=RecommendRecipe.new
      eve.say(id+"ご飯にする？\n"+food.call("なんでもいい")+"食べたいものがあれば「ご飯:食べたいもの」で指定してね！", status.id)
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
