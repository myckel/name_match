# require 'damerau-levenshtein'
require 'byebug'
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

def name_match(known_names, name)
  # Split incoming name into parts (split by space)
  incoming_name_parts = name.split

  # Iterate through each known name, looking for a match
  known_names.any? do |known_name|
    # Split the known name into parts
    known_name_parts = known_name.split

    # Find the intersection of the known name parts and incoming name parts
    intersection = known_name_parts & incoming_name_parts

    # If the known name is the same as the incoming name, return true
    # This checks cases like 1.1, 1.2, 4.1, 4.2
    next true if known_name == name

    # If the last name in both known name and incoming name are the same
    # and if either of them has the same number of parts as the intersection, return true
    # This checks cases like 2.1, 2.2, 3.1
    next true if known_name_parts.last == incoming_name_parts.last && [known_name_parts.size, incoming_name_parts.size].include?(intersection.size)

    # If both the known name and incoming name have three parts
    if known_name_parts.size == 3 && incoming_name_parts.size == 3
      # If exactly two parts are identical
      if intersection.size == 2
        # Calculate the parts of the incoming name that are not in the known name
        difference = incoming_name_parts - known_name_parts
        # If there is a part of the incoming name not in the known name
        # and if there's a part in the known name that starts with the same letter as the different part, return true
        # This checks cases like 5.1, 5.2, 5.5, 6.1, 6.2, 6.3
        if difference.size > 0 && known_name_parts.any? { |part| part[0] == difference.first[0] }
          next true
        else
          # Check if the middle initial of the known name matches the middle name of the incoming name, if not, return false
          # This checks cases like 1.3, 2.3, 3.2, 3.3, 4.3, 5.3, 5.4
          next false unless known_name_parts[1][0] == incoming_name_parts[1][0]
        end
      end
    end

    # If exactly two parts are identical
    if intersection.size == 2
      # Calculate the parts of the incoming name that are not in the known name
      difference = incoming_name_parts - known_name_parts
      # If there is a part of the incoming name not in the known name
      # and if there's a part in the known name that starts with the same letter as the different part, return true
      # This checks cases like 5.1, 5.2, 5.5, 6.1, 6.2, 6.3
      next true if difference.size > 0 && known_name_parts.any? { |part| part[0] == difference.first[0] }
    end

    # If the known name and incoming name have the same number of parts
    if incoming_name_parts.size == known_name_parts.size
      # Calculate the Damerau-Levenshtein distance between each pair of corresponding parts
      distance_arr = incoming_name_parts.map.with_index do |word, index|
        # DamerauLevenshtein.distance(word, known_name_parts[index])
        damerau_levenshtein_distance(word, known_name_parts[index])
      end
      # If the total Damerau-Levenshtein distance is less than or equal to the number of parts in the name
      # and if there is no part with a Damerau-Levenshtein distance of 2, return true
      # This checks cases like 7.1, 7.2, 7.3
      next true if distance_arr.reduce(:+) <= incoming_name_parts.size && !distance_arr.include?(2)
    end

    # If less than two parts are identical, return false
    # This checks cases like 6.4
    next false if intersection.size < 2
  end
end


def test
  known_names = ["Alphonse Gabriel Capone", "Al Capone"]
  p 'error case 1.1' unless name_match(known_names, "Alphonse Gabriel Capone")
  p 'error case 1.2' unless name_match(known_names, "Al Capone")
  p 'error case 1.3' if name_match(known_names, "Alphonse Francis Capone")

  known_names = ["Alphonse Capone"]
  p 'error case 2.1' unless name_match(known_names, "Alphonse Gabriel Capone")
  p 'error case 2.2' unless name_match(known_names, "Alphonse Francis Capone")
  p 'error case 2.3' if name_match(known_names, "Alexander Capone")

  known_names = ["Alphonse Gabriel Capone"]
  p 'error case 3.1' unless name_match(known_names, "Alphonse Capone")
  p 'error case 3.2' if name_match(known_names, "'Alphonse Francis Capone'")
  p 'error case 3.3' if name_match(known_names, "Alexander Capone")

  known_names = ["Alphonse Gabriel Capone", "Alphonse Francis Capone"]
  p 'error case 4.1' unless name_match(known_names, "Alphonse Gabriel Capone")
  p 'error case 4.2' unless name_match(known_names, "Alphonse Francis Capone")
  p 'error case 4.3' if name_match(known_names, "Alphonse Edward Capone")

  known_names = ["Alphonse Gabriel Capone", "Alphonse F Capone"]
  p 'error case 5.1' unless name_match(known_names, "Alphonse G Capone")
  p 'error case 5.2' unless name_match(known_names, "Alphonse Francis Capone")
  p 'error case 5.3' if name_match(known_names, "Alphonse E Capone")
  p 'error case 5.4' if name_match(known_names, "Alphonse Edward Capone")
  p 'error case 5.5' unless name_match(known_names, "Alphonse Gregory Capone")

  known_names = ["Alphonse Gabriel Capone"]
  p 'error case 6.1' unless name_match(known_names, "Gabriel Alphonse Capone")
  p 'error case 6.2' unless name_match(known_names, "Gabriel Capone")
  p 'error case 6.3' unless name_match(known_names, "Gabriel A Capone")
  p 'error case 6.4' if name_match(known_names, "Capone Francis Alphonse")

  known_names = ["Alphonse Capone"]
  p 'error case 7.1' if name_match(known_names, "Alphonse Capone Gabriel")
  p 'error case 7.2' if name_match(known_names, "Capone Alphonse Gabriel")
  p 'error case 7.3' if name_match(known_names, "Capone Gabriel")
end

test


