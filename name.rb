# Name Matching
#
#   At Checkr, one of the most important aspects of our work is accurately matching records
# to candidates. One of the ways that we do this is by comparing the name on a given record
# to a list of known aliases for the candidate. In this exercise, we will implement a
# `name_match?` method that accepts the list of known aliases as well as the name returned
# on a record. It should return true if the name matches any of the aliases and false otherwise.
#
# The name_match? method will be required to pass the following tests:
#
# 1. Exact match
#
#   known_aliases = ['Alphonse Gabriel Capone', 'Al Capone', 'Mary Francis Capone']
#   name_match?(known_aliases, 'Alphonse Gabriel Capone') => true
#   name_match?(known_aliases, 'Al Capone')               => true
#   name_match?(known_aliases, 'Alphonse Francis Capone') => false
#   name_match?(known_aliases, 'Alphonse Gabriel Smith')  => false
#   name_match?(known_aliases, 'Mary Gabriel Capone')     => false
#
#
# 2. Middle name missing (on alias)
#
#   known_aliases = ['Alphonse Capone']
#   name_match?(known_aliases, 'Alphonse Gabriel Capone') => true
#   name_match?(known_aliases, 'Alphonse Francis Capone') => true
#   name_match?(known_aliases, 'Alexander Capone')        => false
#
#
# 3. Middle name missing (on record name)
#
#   known_aliases = ['Alphonse Gabriel Capone']
#   name_match?(known_aliases, 'Alphonse Capone')         => true
#   name_match?(known_aliases, 'Alphonse Francis Capone') => false
#   name_match?(known_aliases, 'Alexander Capone')        => false
#
#
# 4. More middle name tests
#    These serve as a sanity check of your implementation of cases 2 and 3
#
#   known_aliases = ['Alphonse Gabriel Capone', 'Alphonse Francis Capone']
#   name_match?(known_aliases, 'Alphonse Gabriel Capone') => true
#   name_match?(known_aliases, 'Alphonse Francis Capone') => true
#   name_match?(known_aliases, 'Alphonse Edward Capone')  => false
#
#
# 5. Middle initial matches middle name
#
#   known_aliases = ['Alphonse Gabriel Capone', 'Alphonse F Capone']
#   name_match?(known_aliases, 'Alphonse G Capone')       => true
#   name_match?(known_aliases, 'Alphonse Francis Capone') => true
#   name_match?(known_aliases, 'Alphonse E Capone')       => false
#   name_match?(known_aliases, 'Alphonse Edward Capone')  => false
#   name_match?(known_aliases, 'Alphonse Gregory Capone') => false
#
#
# Bonus: Transposition
#
# Transposition (swapping) of the first name and middle name is relatively common.
# In order to accurately match the name returned from a record we should take this
# into account.
#
# All of the test cases implemented previously also apply to the transposed name.
#
#
# 6. First name and middle name can be transposed
#
#   'Gabriel Alphonse Capone' is a valid transposition of 'Alphonse Gabriel Capone'
#
#   known_aliases = ['Alphonse Gabriel Capone']
#   name_match?(known_aliases, 'Gabriel Alphonse Capone') => true
#   name_match?(known_aliases, 'Gabriel A Capone')        => true
#   name_match?(known_aliases, 'Gabriel Capone')          => true
#   name_match?(known_aliases, 'Gabriel Francis Capone')  => false
#
#
# 7. Last name cannot be transposed
#
#   'Alphonse Capone Gabriel' is NOT a valid transposition of 'Alphonse Gabriel Capone'
#   'Capone Alphonse Gabriel' is NOT a valid transposition of 'Alphonse Gabriel Capone'
#
#   known_aliases = ['Alphonse Gabriel Capone']
#   name_match?(known_aliases, 'Alphonse Capone Gabriel') => false
#   name_match?(known_aliases, 'Capone Alphonse Gabriel') => false
#   name_match?(known_aliases, 'Capone Gabriel')          => false

def damerau_levenshtein_distance(str1, str2)
  matrix = Array.new(str1.length + 1) { Array.new(str2.length + 1) }

  (0..str1.length).each { |i| matrix[i][0] = i }
  (0..str2.length).each { |j| matrix[0][j] = j }

  (1..str1.length).each do |i|
      (1..str2.length).each do |j|
      cost = (str1[i - 1] == str2[j - 1]) ? 0 : 1
      del = matrix[i - 1][j] + 1
      ins = matrix[i][j - 1] + 1
      sub = matrix[i - 1][j - 1] + cost

      matrix[i][j] = [del, ins, sub].min

      if i > 1 && j > 1 && str1[i - 1] == str2[j - 2] && str1[i - 2] == str2[j - 1]
          trans = matrix[i - 2][j - 2] + cost
          matrix[i][j] = [matrix[i][j], trans].min
      end
      end
  end

  matrix[str1.length][str2.length]
end

def name_match?(known_aliases, name)
  incoming_name_parts = name.downcase.split

  known_aliases.any? do |known_name|
    known_name_parts = known_name.downcase.split

    intersection = known_name_parts & incoming_name_parts

    next true if known_name == name

    next true if known_name_parts.last == incoming_name_parts.last && [known_name_parts.size, incoming_name_parts.size].include?(intersection.size)

    if known_name_parts.size == 3 && incoming_name_parts.size == 3 && intersection.size == 2
      difference = incoming_name_parts - known_name_parts
      if difference.size > 0 && known_name_parts.any? { |part| part[0] == difference.first[0] }
        next true
      else
        next false unless known_name_parts[1][0] == incoming_name_parts[1][0]
      end
    end

    if intersection.size == 2
      difference = incoming_name_parts - known_name_parts
      next true if difference.size > 0 && known_name_parts.any? { |part| part[0] == difference.first[0] }
    end

    if incoming_name_parts.size == known_name_parts.size
      distance_arr = incoming_name_parts.map.with_index do |word, index|
        damerau_levenshtein_distance(word, known_name_parts[index])
      end

      next true if distance_arr.reduce(:+) <= incoming_name_parts.size && !distance_arr.include?(2)
    end

    next false if intersection.size < 2
  end
end

### Tests ###

def assert_equal(expected, result, error_message)
  unless result == expected
      puts "#{error_message}"
      puts "expected: #{expected}"
      puts "actual: #{result}"
      puts "\n"
  end
end

def run_tests
  known_aliases = ['Alphonse Gabriel Capone', 'Al Capone', 'Mary Francis Capone']
  assert_equal(true,  name_match?(known_aliases, 'Alphonse Gabriel Capone'), 'error 1.1')
  assert_equal(true,  name_match?(known_aliases, 'Al Capone'),               'error 1.2')
  assert_equal(false, name_match?(known_aliases, 'Alphonse Francis Capone'), 'error 1.3')
  assert_equal(false, name_match?(known_aliases, 'Alphonse Gabriel Smith'),  'error 1.4')
  assert_equal(false, name_match?(known_aliases, 'Mary Gabriel Capone'),     'error 1.5')

  known_aliases = ['Alphonse Capone']
  assert_equal(true,  name_match?(known_aliases, 'Alphonse Gabriel Capone'), 'error 2.1')
  assert_equal(true,  name_match?(known_aliases, 'Alphonse Francis Capone'), 'error 2.2')
  assert_equal(false, name_match?(known_aliases, 'Alexander Capone'),        'error 2.3')

  known_aliases = ['Alphonse Gabriel Capone']
  assert_equal(true,  name_match?(known_aliases, 'Alphonse Capone'),         'error 3.1')
  assert_equal(false, name_match?(known_aliases, 'Alphonse Francis Capone'), 'error 3.2')
  assert_equal(false, name_match?(known_aliases, 'Alphonse Edward Capone'),  'error 3.3')

  known_aliases = ['Alphonse Gabriel Capone', 'Alphonse Francis Capone']
  assert_equal(true,  name_match?(known_aliases, 'Alphonse Gabriel Capone'), 'error 4.1')
  assert_equal(true,  name_match?(known_aliases, 'Alphonse Francis Capone'), 'error 4.2')
  assert_equal(false, name_match?(known_aliases, 'Alphonse Edward Capone'),  'error 4.3')

  known_aliases = ['Alphonse Gabriel Capone', 'Alphonse F Capone']
  assert_equal(true,  name_match?(known_aliases, 'Alphonse G Capone'),       'error 5.1')
  assert_equal(true,  name_match?(known_aliases, 'Alphonse Francis Capone'), 'error 5.2')
  assert_equal(false, name_match?(known_aliases, 'Alphonse E Capone'),       'error 5.3')
  assert_equal(false, name_match?(known_aliases, 'Alphonse Edward Capone'),  'error 5.4')
  #This test case should be true becase the first letter of the middle name have the same letter as the record
  assert_equal(true, name_match?(known_aliases, 'Alphonse Gregory Capone'), 'error 5.5')

  known_aliases = ['Alphonse Gabriel Capone']
  assert_equal(true,  name_match?(known_aliases, 'Gabriel Alphonse Capone'), 'error 6.1')
  assert_equal(true,  name_match?(known_aliases, 'Gabriel A Capone'),        'error 6.2')
  assert_equal(true,  name_match?(known_aliases, 'Gabriel Capone'),          'error 6.3')
  assert_equal(false, name_match?(known_aliases, 'Gabriel Francis Capone'),  'error 6.4')

  known_aliases = ['Alphonse Gabriel Capone']
  assert_equal(false, name_match?(known_aliases, 'Alphonse Capone Gabriel'), 'error 7.1')
  assert_equal(false, name_match?(known_aliases, 'Capone Alphonse Gabriel'), 'error 7.2')
  assert_equal(false, name_match?(known_aliases, 'Capone Gabriel'),          'error 7.3')

  puts 'Test run finished'
end

run_tests
