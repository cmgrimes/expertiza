require 'automated_metareview/negations'
require 'automated_metareview/constants'

class SentenceState
  attr_accessor :broken_sentences
  def identify_sentence_state(str_with_pos_tags)
    # puts("**** Inside identify_sentence_state #{str_with_pos_tags}")
    #break the sentence at the co-ordinating conjunction
    num_conjunctions = break_at_coordinating_conjunctions(str_with_pos_tags)

    states_array = Array.new
    if(@broken_sentences == nil)
      states_array[0] = sentence_state(str_with_pos_tags)
      #identifying states for each of the sentence segments
    else
      for i in (0..num_conjunctions)
        if(!@broken_sentences[i].nil?)
          states_array[i] = sentence_state(@broken_sentences[i])
        end
      end
    end
    return states_array
  end #end of the methods
      #------------------------------------------#------------------------------------------
  def break_at_coordinating_conjunctions(str_with_pos_tags)
    st = str_with_pos_tags.split(" ")
    count = st.length
    counter = 0

    @broken_sentences = Array.new
    #if the sentence contains a co-ordinating conjunction
    if(str_with_pos_tags.include?("CC"))
      counter = 0
      temp = ""
      for i in (0..count-1)
        ps = st[i]
        if(!ps.nil? and ps.include?("CC"))
          @broken_sentences[counter] = temp #for "run/NN on/IN..."
          counter+=1
          temp = ps[0..ps.index("/")]
          #the CC or IN goes as part of the following sentence
        elsif (!ps.nil? and !ps.include?("CC"))
          temp = temp +" "+ ps[0..ps.index("/")]
        end
      end
      if(!temp.empty?) #setting the last sentence segment
        @broken_sentences[counter] = temp
        counter+=1
      end
    else
      @broken_sentences[counter] = str_with_pos_tags
      counter+=1
    end
    return counter
  end #end of the method
      #------------------------------------------#------------------------------------------

      #Checking if the token is a negative token
  def sentence_state(str_with_pos_tags)

    #checking single tokens for negated words
    st = str_with_pos_tags.split(" ")

    num_of_tokens, tokens = parse_sentence_tokens(st)

    #initialize state variables so that the original sentence state is positive
    state = POSITIVE
    current_state = State.factory(state)
    prev_negative_word = false

    for j  in (0..num_of_tokens-1)
      #get current token type
      current_token_type = get_token_type(tokens[j..num_of_tokens-1])

      #Have State class get current state based on current state, current_token_type, and if there was a prev_negative_word
      current_state = State.factory(current_state.next_state(current_token_type, prev_negative_word))

      #setting the prevNegativeWord
      NEGATIVE_EMPHASIS_WORDS.each do |e|
        if tokens[j].casecmp(e)
          prev_negative_word = true
        end
      end

    end #end of for loop

    current_state.get_state()
  end

  def get_token_type(current_tokens)
    type_methods = [self.method(:is_negative_word), self.method(:is_negative_descriptor), self.method(:is_suggestive), self.method(:is_negative_phrase), self.method(:is_suggestive_phrase)]
    current_token_type = POSITIVE
    type_methods.each do |what_type_is|
      if current_token_type == POSITIVE
        current_token_type = what_type_is.call(current_tokens)
      end
    end
    current_token_type
  end

  def parse_sentence_tokens(sentence_pieces)
    num_tokens = 0
    tokens = Array.new

    punctuation = ['.', ',', '!', ';']
    sentence_pieces.each do |sp|
      #remove tag from sentence word
      if sp.include?("/")
        sp = sp[0..sp.index("/")-1]
      end

      valid_token = true
      punctuation.each do |p|
        if sp.include?(p)
          valid_token = false
        end
      end
      if valid_token
        tokens[num_tokens] = sp
        num_tokens+=1
      end
    end
    #end of the for loop
    return num_tokens, tokens
  end

#------------------------------------------#------------------------------------------

#Checking if the token is a negative token
  def is_negative_word(word_array)
    word = word_array.first
    not_negated = POSITIVE
    for i in (0..NEGATED_WORDS.length - 1)
      if word.casecmp(NEGATED_WORDS[i]) == 0
        not_negated =  NEGATIVE_WORD #indicates negation found
        break
      end
    end
    not_negated
  end
#------------------------------------------#------------------------------------------

#Checking if the token is a negative token
  def is_negative_descriptor(word_array)
    word = word_array.first
    not_negated = POSITIVE
    for i in (0..NEGATIVE_DESCRIPTORS.length - 1)
      if word.casecmp(NEGATIVE_DESCRIPTORS[i]) == 0
        not_negated =  NEGATIVE_DESCRIPTOR #indicates negation found
        break
      end
    end
    not_negated
  end

#------------------------------------------#------------------------------------------

#Checking if the phrase is negative
  def is_negative_phrase(word_array)
    not_negated = POSITIVE
    if word_array.size > 1
      phrase = word_array[0]+" "+word_array[1]

      for i in (0..NEGATIVE_PHRASES.length - 1)
        if phrase.casecmp(NEGATIVE_PHRASES[i]) == 0
          not_negated =  NEGATIVE_PHRASE #indicates negation found
          break
        end
      end
    end

    not_negated
  end

#------------------------------------------#------------------------------------------
#Checking if the token is a suggestive token
  def is_suggestive(word_array)
    word = word_array.first
    not_suggestive = POSITIVE
    #puts "inside is_suggestive for token:: #{word}"
    for i in (0..SUGGESTIVE_WORDS.length - 1)
      if word.casecmp(SUGGESTIVE_WORDS[i]) == 0
        not_suggestive =  SUGGESTIVE #indicates negation found
        break
      end
    end
    not_suggestive
  end
#------------------------------------------#------------------------------------------

#Checking if the PHRASE is suggestive
  def is_suggestive_phrase(word_array)
    not_suggestive = POSITIVE
    if word_array.size > 1
      phrase = word_array[0]+" "+word_array[1]
      for i in (0..SUGGESTIVE_PHRASES.length - 1)
        if phrase.casecmp(SUGGESTIVE_PHRASES[i]) == 0
          not_suggestive =  SUGGESTIVE #indicates negation found
          break
        end
      end
    end
    not_suggestive
  end

end #end of the class
