class Person
  def initialize(name, age)
    @name = name
    @age = age
  end

  def who_am_i?
    puts "My name is #{@name}"
  end

  def how_old_am_i?
    puts "I'm #{@age} years old"
  end

  def self.help
    puts 'how_old_am_i?, who_am_i?'
  end
end

Person.class_eval do
  def who_am_i?
    puts "My name is not #{@name}"
  end
end

ahmed = Person.new('Ahmed', 15)
ahmed.who_am_i?
ahmed.how_old_am_i?
Person.help
Person.class_eval do
  def help
    puts 'who_am_i?, how_old_am_i?'
  end
end
Person.help
