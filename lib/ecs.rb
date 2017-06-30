module Entities

  def self.init
    @entity_list = []

    @prefabs = G.entity_prefabs.map do |k, v|
      [k.to_sym, v.map(&:to_sym)]
    end.to_h
  end


  def self.add *components
    e = {}

    components.each do |component|
      e[component] = Component.send component
    end

    yield e

    @entity_list << e
  end


  def self.prefab name, &block
    add *@prefabs[name], &block
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

end


module Component; end
module System; end
