require_relative 'view'
require 'open-uri'
require 'nokogiri'

class Controller
  def initialize(cookbook_repo) # Expecting Cookbook instance
    @cookbook = cookbook_repo
    @view = View.new
  end

  def list
    display_recipes
  end

  def create
    name = @view.ask_for('Enter the name')
    description = @view.ask_for('Enter a description')
    rating = @view.ask_for('Enter a rating').to_f
    prep_time = @view.ask_for('Enter the preparation time')
    recipe = Recipe.new({
                          name: name,
                          description: description,
                          rating: rating,
                          prep_time: prep_time
                        })
    @cookbook.add_recipe(recipe)
  end

  def destroy
    display_recipes
    index = @view.ask_for('Enter the index').to_i
    @cookbook.remove_recipe(index)
    @view.success
  end

  def mark_as_done
    # Display the list
    display_recipes
    # Ask for the index
    index = @view.ask_for('Enter the index').to_i
    # Mark as done
    @cookbook.mark_recipe_as_done(index)
  end

  def import
    # Display the user a message to select an ingredient (@view.ask_for('CUSTOMIZE'))
    # Ingredient input by the user (@view.ask_for('CUSTOMIZE'))
    ingredient = @view.ask_for('What ingredient would you like a recipe for?')

    # Display of informational message (@view.INFORMATIONAL)
    @view.info("Looking for #{ingredient} recipes on the AllRecipes...")

    # Get the recipes from AllRecipes
    url = "https://www.allrecipes.com/search/results/?wt=#{ingredient}"
    raw_html = open(url).read # String
    doc = Nokogiri::HTML(raw_html) # Nokogiri::HTML::Document
    results = doc.search('.fixed-recipe-card') # Array (like)
    top_results = results.first(5).map do |card|
      title_element = card.search('a.fixed-recipe-card__title-link').first
      link = title_element['href']
      title = title_element.text.strip
      description = card.search('.fixed-recipe-card__description').text.strip
      rating = card.search('.stars').first['data-ratingstars'].to_f.round(2)

      # OPEN THE DETAIL PAGE
      recipe_raw_html = open(link).read # String
      recipe_doc = Nokogiri::HTML(recipe_raw_html) # Nokogiri::HTML::Document
      left_col = recipe_doc.search('.recipe-meta-container .two-subcol-content-wrapper').first
      total_time = left_col.search('.recipe-meta-item').last
      prep_time = ''
      prep_time = total_time.search('.recipe-meta-item-body').text.strip if total_time
      # Parse the recipes Strings/Nokogiri => [] of Recipes
      Recipe.new({
                   name: title,
                   description: description,
                   rating: rating,
                   prep_time: prep_time
                 })
    end

    # Display the results (@view.display_list(array_of_recipes))
    @view.display_list(top_results)
    # Display the user a message to select an Index (@view.ask_for('CUSTOMIZE'))
    # Index is input by the user (@view.ask_for('CUSTOMIZE'))
    index = @view.ask_for('Which recipe would you like to import? (enter index)').to_i

    recipe = top_results[index]
    # Display of informational message (@view.INFORMATIONAL)
    @view.info("Importing #{recipe.name}...")

    @cookbook.add_recipe(recipe)
  end

  private

  def display_recipes
    @view.display_list(@cookbook.all)
  end
end
