class View
  def display_list(array_of_recipes)
    puts "These are your recipes 👇"
    array_of_recipes.each_with_index do |recipe_instance, index| # Recipe, Integer
      status = recipe_instance.done? ? 'X' : ' '
      puts "#{index}.  [#{status}]  #{recipe_instance.name} (#{recipe_instance.rating.round}/5) | #{recipe_instance.prep_time}"
    end
  end

  def ask_for(message)
    puts message
    gets.chomp
  end

  def info(message)
    puts message
  end

  def success
    puts ' Done ✅'
  end
end
