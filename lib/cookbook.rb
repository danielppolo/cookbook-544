require 'csv'
require_relative 'recipe'
class Cookbook
  def initialize(csv_path)
    @csv_path = csv_path
    @recipes = []
    load_csv
  end

  def all
    @recipes
  end

  def add_recipe(recipe_instance)
    # In-memory collection
    @recipes << recipe_instance
    # Persistent CSV
    save_csv
  end

  def remove_recipe(recipe_index)
    # In-memory collection
    @recipes.delete_at(recipe_index)
    # Persistent CSV
    save_csv
  end

  def mark_recipe_as_done(recipe_index)
    # In-memory collection
    @recipes[recipe_index].mark_as_done!
    # Persistent CSV
    save_csv
  end


  private

  def load_csv
    CSV.foreach(@csv_path) do |row|
      # Array -> Recipe
      name = row[0]
      description = row[1]
      rating = row[2].to_f
      # "true" => true
      # "false" => false
      done = row[3] == "true"
      prep_time = row[4]
      @recipes << Recipe.new({
                               name: name,
                               description: description,
                               rating: rating,
                               done: done,
                               prep_time: prep_time
                             })
    end
  end

  def save_csv
    CSV.open(@csv_path, 'wb') do |file|
      @recipes.each do |recipe| # recipe instance
        # Recipe -> Array
        name = recipe.name
        description = recipe.description
        rating = recipe.rating
        done = recipe.done?
        prep_time = recipe.prep_time
        record = [name, description, rating, done, prep_time]
        file << record
      end
    end
  end
end
