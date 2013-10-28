require 'automated_metareview/negations'
require 'automated_metareview/constants'

class SentenceState
  attr_accessor :broken_sentences
  def identify_sentence_state(str_with_pos_tags)
    # puts("**** Inside identify_sentence_state #{str_with_pos_tags}")
    #break the sentence at the co-ordinating conjunction
    num_conjunctions = break_at_coord_conjunctions(str_with_pos_tags)

    states_array = Array.new
    @broken_sentences.nil? ?
        states_array[0] = sentence_state(str_with_pos_tags) :
        (0..num_conjunctions).each do |i|
          unless @broken_sentences[i].nil?
            states_array[i] = sentence_state(@broken_sentences[i])
          end
        end
    states_array
  end #end of the methods
      #------------------------------------------#------------------------------------------
  def break_at_coord_conjunctions(str_with_pos_tags)
    st = str_with_pos_tags.split(' ')
    counter = 0

    @broken_sentences = Array.new
    #if the sentence contains a co-ordinating conjunction
    if str_with_pos_tags.include?('CC')
      counter = 0
      temp = ''
      st.each do |ps|
        if !ps.nil? and ps.include?('CC')
          @broken_sentences[counter] = temp #for "run/NN on/IN..."
          counter+=1
          temp = ps[0..ps.index('/')]
          #the CC or IN goes as part of the following sentence
        elsif !ps.nil? and !ps.include?('CC')
          temp += ' '+ ps[0..ps.index('/')]
        end
      end
      unless temp.empty? #setting the last sentence segment
        @broken_sentences[counter] = temp
        counter+=1
      end
    else
      @broken_sentences[counter] = str_with_pos_tags
      counter+=1
    end
    counter
  end #end of the method
      #------------------------------------------#------------------------------------------

      #Checking if the token is a negative token
  def sentence_state(str_with_pos_tags)

    #checking single tokens for negated words
    st = str_with_pos_tags.split(' ')

    tokens = parse_sentence_tokens(st)

    #initialize state variables so that the original sentence state is positive
    state = POSITIVE
    current_state = State.factory(state)
    prev_negative_word = false

    tokens.each_with_next do |curr_token, next_token|
      #get current token type
      current_token_type = get_token_type([curr_token, next_token])

      #Ask State class to get current state based on current state, current_token_type, and if there was a prev_negative_word
      current_state = State.factory(current_state.next_state(current_token_type, prev_negative_word))

      #setting the prevNegativeWord
      NEGATIVE_EMPHASIS_WORDS.each do |e|
        if curr_token.casecmp(e)
          prev_negative_word = true
        end
      end

    end #end of for loop

    current_state.get_state()
  end

  def get_token_type(current_token)
    type_methods = [self.method(:is_negative_word), self.method(:is_negative_descriptor), self.method(:is_suggestive), self.method(:is_negative_phrase), self.method(:is_suggestive_phrase)]
    current_token_type = POSITIVE
    type_methods.each do |what_type_is|
      if current_token_type == POSITIVE
        current_token_type = what_type_is.(current_token)
      end
    end

    current_token_type
  end

  def parse_sentence_tokens(sentence_pieces)
    num_tokens = 0
    tokens = Array.new

    punctuation = %w(. , ! ;)
    sentence_pieces.each do |sp|
      #remove tag from sentence word
      if sp.include?('/')
        sp = sp[0..sp.index('/')-1]
      end

      valid_token = true
      punctuation.each do |p|
        if sp.include?(p)
          valid_token = false
          break
        end
      end
      if valid_token
        tokens[num_tokens] = sp
        num_tokens+=1
      end
    end
    #end of the for loop
    tokens
  end

#------------------------------------------#------------------------------------------

#Checking if the token is a negative token
  def is_negative_word(token_array)

    token = token_array.first
    token_type = POSITIVE
    NEGATED_WORDS.each do |nw|
      if token.casecmp(nw) == 0
        token_type = NEGATIVE_WORD
        break
      end
    end
    token_type
  end
#------------------------------------------#------------------------------------------

#Checking if the token is a negative token
  def is_negative_descriptor(token_array)
    token = token_array.first
    token_type = POSITIVE
    NEGATIVE_DESCRIPTORS.each do |nd|
      if token.casecmp(nd) == 0
        token_type =  NEGATIVE_DESCRIPTOR #indicates negation found
        break
      end
    end
    token_type
  end

#------------------------------------------#------------------------------------------

#Checking if the phrase is negative
  def is_negative_phrase(token_array)

    token_type = POSITIVE
    unless token_array[1].nil?
      phrase = token_array[0]+' '+token_array[1]

      NEGATIVE_PHRASES.each do |np|
        if phrase.casecmp(np) == 0
          token_type = NEGATIVE_PHRASE#indicates negation found
          break
        end
      end
    end
    token_type
  end

#------------------------------------------#------------------------------------------
#Checking if the token is a suggestive token
  def is_suggestive(token_array)
    token = token_array.first
    token_type = POSITIVE
    #puts "inside is_suggestive for token:: #{word}"
    SUGGESTIVE_WORDS.each do |sw|
      if token.casecmp(sw) == 0
        token_type =  SUGGESTIVE #indicates negation found
        break
      end
    end
    token_type
  end
#------------------------------------------#------------------------------------------

#Checking if the PHRASE is suggestive
  def is_suggestive_phrase(token_array)
    token_type = POSITIVE
    unless token_array[1].nil?
      phrase = token_array[0]+' '+token_array[1]
      SUGGESTIVE_PHRASES.each do |sp|
        if phrase.casecmp(sp) == 0
          token_type = SUGGESTIVE #indicates negation found
          break
        end
      end
    end
    token_type
  end

end #end of the class

class Array
  def each_with_next(&block)
    [*self, nil].each_cons(2, &block)
  end
end