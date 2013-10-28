require 'automated_metareview/negations'
require 'automated_metareview/constants'

class SentenceState
  @interim_noun_verb
  @state
  @@prev_negative_word

  # Make a new state instance based on the type of the current_state
  def factory(state)
    {POSITIVE => PositiveState, NEGATIVE_DESCRIPTOR => NegativeDescriptorState, NEGATIVE_PHRASE => NegativePhraseState, SUGGESTIVE => SuggestiveState, NEGATIVE_WORD => NegativeWordState}[state].new()
  end

  def identify_sentence_state(str_with_pos_tags)
    # puts("**** Inside identify_sentence_state #{str_with_pos_tags}")
    #break the sentence at the co-ordinating conjunction
    sentence = TaggedSentence.new(str_with_pos_tags)
    sentences_sections = sentence.break_at_coord_conjunctions()

    states_array = Array.new
    i = 0
    sentences_sections.each do |section_tokens|
      states_array[i] = sentence_state(section_tokens)
      i+=1
    end
    
    states_array
  end #end of the methods

  def sentence_state(sentence_tokens) #str_with_pos_tags)
    #initialize state variables so that the original sentence state is positive
    @state = POSITIVE
    current_state = factory(@state)
    @@prev_negative_word = false

    @interim_noun_verb = false
    sentence_tokens.each_with_next do |curr_token, next_token|
      #get current token type
      current_token_type = get_token_type([curr_token, next_token])

      #Ask State class to get current state based on current state, current_token_type, and if there was a prev_negative_word

      current_state = factory(current_state.next_state(current_token_type))



      #setting the prevNegativeWord
      NEGATIVE_EMPHASIS_WORDS.each do |e|
        if curr_token.casecmp(e)
          @@prev_negative_word = true
        end
      end

    end #end of for loop

    current_state.get_state()
  end
  def if_negative_emphasis(state1, state2)


  end
  def get_token_type(current_token)
    #type_methods = [self.method(:is_negative_word), self.method(:is_negative_descriptor), self.method(:is_suggestive), self.method(:is_negative_phrase), self.method(:is_suggestive_phrase)]
    is_word = lambda { |c| c[0]}
    is_phrase = lambda {|c| c[1].nil? ? nil : c[0]+' '+c[1]}

    types = {NEGATED_WORDS => [is_word, NEGATIVE_WORD], NEGATIVE_DESCRIPTORS => [is_word, NEGATIVE_DESCRIPTOR], SUGGESTIVE_WORDS => [is_word, SUGGESTIVE], NEGATIVE_PHRASES => [is_phrase,NEGATIVE_PHRASE], SUGGESTIVE_PHRASES => [is_phrase, SUGGESTIVE]}
    current_token_type = POSITIVE
    types.each do |type, w|
      get_word_or_phrase = w[0]
      word_or_phrase_type = w[1]
      token = get_word_or_phrase.(current_token)
      unless token.nil?
        type.each do |t|
            if token.casecmp(t) == 0
              current_token_type = word_or_phrase_type
              break
            end
        end
      end
    end
    current_token_type
  end
  def next_state(current_token_type)
    #@@prev_negative_word = prev_negative_word
    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]
    method.call()
    if @state != POSITIVE
      set_interim_noun_verb(false) #resetting
    end
    @state
  end
  #SentenceState is responsible for keeping track of interim words
  def get_interim_noun_verb
    @interim_noun_verb
  end
  def set_interim_noun_verb(interim_noun_verb)
    @interim_noun_verb = interim_noun_verb
  end

  #if there is an interim word between two states, it will become state1 else it will be state2
  def if_interim_then_state_is(state1, state2)
    if @interim_noun_verb   #there are some words in between
      state = state1
    else
      state = state2
    end
    state
  end
end #end of the class

class Array
  def each_with_next(&block)
    [*self, nil].each_cons(2, &block)
  end
end