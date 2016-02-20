# coding: utf-8
require 'open-uri'
require 'json'
require 'yaml'
#require 'natto'
require 'MeCab'

class RecommendRecipe
    keys=YAML.load_file('./config.yml')
    RECIPE_CATEGORY_URL="https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20121121?format=json&elements=categoryName%2CcategoryId%2CparentCategoryId&categoryType=medium&applicationId=#{keys['rakuten_api_id']}"
    RECIPES_URL="https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20121121?format=json&formatVersion=2&applicationId=#{keys['rakuten_api_id']}&categoryId="

  def call(food)
    hearing(food)
  end

  private

  def hearing(food)
    results = recipe_categories
    if(food=='なんでもいい')
      recipe_category_id = results[results.keys.sample]
      recipe = choose_recipe(recipe_category_id)
      return "#{food}なら、#{recipe['recipeTitle']} とかはどう？ #{recipe['recipeUrl']}"+' <Supported by RWS>'
    else
      recipe_category_id = results.fetch(food, nil)
      if(recipe_category_id.nil?)

        words=[]
        #require 'MeCab'の場合
        mc=MeCab::Tagger.new()
        n=mc.parseToNode(food)
        while(n)
          if(n.feature.split(',')[0]=="名詞")
            words.push(n.surface)
          elsif(words.size>0)
            food=words.join("")
            break
          end
          n=n.next
        end

        #require 'natto'の場合
        # nt=Natto::MeCab.new
        # nt.parse(food){|n|
        #   if(n.feature.split(',')[0]=="名詞")
        #     words.push(n.surface)
        #   elsif(words.size>0)
        #     food=words.join("")
        #     break
        #   end
        # }
        recipe_category_id = results.fetch(food, nil)
        if(recipe_category_id.nil?)
          return "#{food}だとわからないからもうちょっと詳しく教えて(漢字⇆ひらがなにするといいかも)"
        else
          recipe = choose_recipe(recipe_category_id)
          return "#{food}だと、#{recipe['recipeTitle']} とかはどう？ #{recipe['recipeUrl']}"+' <Supported by RWS>'
        end


      else
        recipe = choose_recipe(recipe_category_id)
        return "#{food}だと、#{recipe['recipeTitle']} とかはどう？ #{recipe['recipeUrl']}"+' <Supported by RWS>'
      end
    end
  end

  def recipe_categories
    response=open(RECIPE_CATEGORY_URL).read
    results=JSON.parse(response.force_encoding('UTF-8'))
    return results["result"]["medium"].map{|result| [result['categoryName'], "#{result['parentCategoryId']}-#{result['categoryId']}"]}.to_h
  end

  def choose_recipe(recipe_category_id)
    response=open("#{RECIPES_URL}#{recipe_category_id}").read
    results=JSON.parse(response.force_encoding('UTF-8'))
    return results['result'][Random.rand(1 .. results['result'].count-1)]
  end
end
