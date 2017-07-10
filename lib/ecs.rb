module Entities

  def self.init
    @entity_list = []

    build_prefabs
  end


  def self.add *components
    e = {}

    components.each do |component|
      e[component] = Component.send component
    end

    yield e

    @entity_list << e

    return e
  end


  def self.prefab name
    current_prefab = @prefabs[name]

    components = current_prefab.map(&:first)

    entity = add *components do |e|
      current_prefab.each do |component, properties|
        next if properties.nil?

        e[component] = e[component].merge properties
      end
    end

    yield entity
  end


  def self.each
    @entity_list.each do |e|
      yield e
    end
  end


  def self.find_by_component component
    @entity_list.find do |e|
      e.include? component
    end
  end


  def self.find_by_components *components
    @entity_list.find do |e|
      components.all? do |component|
        e.include? component
      end
    end
  end


  def self.filter_by_component component
    @entity_list.select do |e|
      e.include? component
    end
  end


  def self.filter_by_components *components
    @entity_list.select do |e|
      components.all? do |component|
        e.include? component
      end
    end
  end


  private_class_method def self.build_prefabs
    @prefabs = {}

    PREFABS.entity_prefabs.each do |name, components|
      @prefabs[name.to_sym] = components
    end
  end

end


module Component; end
module System; end
