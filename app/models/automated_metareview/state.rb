require 'automated_metareview/negations'
require 'automated_metareview/constants'
class State
  @interim_noun_verb
  def State.factory(state, interim_noun_verb)
    {POSITIVE => PositiveState, NEGATIVE_DESCRIPTOR => NegativeDescriptorState, NEGATIVE_PHRASE => NegativePhraseState, SUGGESTIVE => SuggestiveState, NEGATIVE_WORD => NegativeWordState}[state].new(interim_noun_verb)
  end
  def initialize(interim_noun_verb)
    @interim_noun_verb = interim_noun_verb
  end
  def get_interim_noun_verb
    return @interim_noun_verb
  end
  def set_interim_noun_verb(interim_noun_verb)
    @interim_noun_verb = interim_noun_verb
  end
end
class PositiveState < State
  @state
  def next_state(current_token_type, prev_negative_word)
    @state = get_state()
    @state = current_token_type
    return @state 
  end
  def get_state
    #puts "positive"
    return POSITIVE
  end

end
class NegativeWordState < State

  @state
  @prev_negative_word


  def next_state(current_token_type, prev_negative_word)
    @prev_negative_word = prev_negative_word

    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]

    method.call()

    if !(@state == POSITIVE)
      set_interim_noun_verb(false) #resetting
    end
    
    return @state 
  end
  def negative_word
      #puts "next token is negative"
      if(@prev_negative_word.casecmp("NO") != 0 and @prev_negative_word.casecmp("NEVER") != 0 and @prev_negative_word.casecmp("NONE") != 0)
        @state = POSITIVE #e.g: "not had no work..", "doesn't have no work..", "its not that it doesn't bother me..."
      else
        @state = NEGATIVE_WORD #e.g: "no it doesn't help", "no there is no use for ..."
      end
  end
  def positive
    set_interim_noun_verb(true)
    @state = get_state()
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = POSITIVE
    #puts "next token is negative"
  end
  def negative_phrase
    @state = POSITIVE
    #puts "next token is negative phrase"
  end
  def suggestive
    if(get_interim_noun_verb() == true) #there are some words in between
      @state = NEGATIVE_WORD
    else
      @state = SUGGESTIVE #e.g.:"I do not(-) suggest(S) ..."
    end
    #puts "next token is suggestive"
  end
  def get_state
    #puts "negative_word"
    @state = NEGATIVE_WORD
  end
end
class NegativePhraseState < State
  @state
  @prev_negative_word


  def next_state(current_token_type, prev_negative_word)
    @prev_negative_word = prev_negative_word

    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]

    get_state()
    method.call()

    if !(@state == POSITIVE)
      set_interim_noun_verb(false) #resetting
    end

    return @state 

  end
  def negative_word
    if(get_interim_noun_verb() == true)#there are some words in between
      @state = NEGATIVE_WORD #e.g."It is too short the text and doesn't"
    else
      @state = POSITIVE #e.g."It is too short not to contain.."
    end
    #puts "next token is negative"
  end
  def positive
    set_interim_noun_verb(true)
    @state = get_state()
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = NEGATIVE_DESCRIPTOR
    #puts "next token is negative"
  end
  def negative_phrase
    @state = NEGATIVE_PHRASE
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE #e.g.:"I too short and I suggest ..."
    #puts "next token is suggestive"
  end
  def get_state
    #puts "negative phrase"
    @state = NEGATIVE_PHRASE
  end
end
class SuggestiveState < State
  @state
  @prev_negative_word


  def next_state(current_token_type, prev_negative_word)
    @prev_negative_word = prev_negative_word

    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]

    method.call()

    set_interim_noun_verb(false) #resetting

    return @state 
  end
  def negative_word
    @state = get_state()
    #puts "next token is negative"
  end
  def positive
    @state = get_state()
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = NEGATIVE_DESCRIPTOR
    #puts "next token is negative"
  end
  def negative_phrase
    @state = NEGATIVE_PHRASE
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = get_state() #e.g.:"I too short and I suggest ..."
    #puts "next token is suggestive"
  end
  def get_state
    #puts "suggestive"
    return SUGGESTIVE
  end
end
class NegativeDescriptorState < State
  @state
  @prev_negative_word
  #@interim_noun_verb

  def next_state(current_token_type, prev_negative_word)
    @prev_negative_word = prev_negative_word
    #
    method = {POSITIVE => self.method(:positive), NEGATIVE_DESCRIPTOR => self.method(:negative_descriptor), NEGATIVE_PHRASE => self.method(:negative_phrase), SUGGESTIVE => self.method(:suggestive), NEGATIVE_WORD => self.method(:negative_word)}[current_token_type]

    method.call()
    if !(@state == POSITIVE)
      set_interim_noun_verb(false) #resetting
    end

    return @state 

  end
  def negative_word
    if(get_interim_noun_verb() == true)#there are some words in between
      @state = NEGATIVE_WORD #e.g: "hard(-) to understand none(-) of the comments"
    else
      @state = POSITIVE #e.g."He hardly not...."
    end
    #puts "next token is negative"
  end
  def positive
    set_interim_noun_verb(true)
    @state = get_state()
    #puts "next token is positive"
  end
  def negative_descriptor
    if(get_interim_noun_verb() == true)#there are some words in between
      @state = NEGATIVE_DESCRIPTOR #e.g:"there is barely any code duplication"
    else
      @state = POSITIVE #e.g."It is hardly confusing..", but what about "it is a little confusing.."
    end
    #puts "next token is negative"
  end
  def negative_phrase
    if(get_interim_noun_verb() == true)#there are some words in between
      @state = NEGATIVE_PHRASE #e.g:"there is barely any code duplication"
    else
      @state = POSITIVE #e.g.:"it is hard and appears to be taken from"
    end
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE #e.g.:"I hardly(-) suggested(S) ..."
    #puts "next token is suggestive"
  end
  def get_state
    #puts "negative_descriptor"
    return NEGATIVE_DESCRIPTOR
  end

end