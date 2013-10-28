require 'automated_metareview/negations'
require 'automated_metareview/constants'

#This is a type of state where the sentence clause is positive
class PositiveState < SentenceState


  def negative_word
    #puts "next token is negative"

    @state = NEGATIVE_WORD
  end
  def positive

    @state = POSITIVE
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
    @state = SUGGESTIVE
    #puts "next token is suggestive"
  end
  def get_state
    #puts "positive"
    POSITIVE
  end
end

#This is a type of state where the sentence clause is negative because of a negative word
class NegativeWordState < SentenceState
  @@prev_negative_word

  def negative_word
    puts "next token is negative"
    puts @@prev_negative_word
    @state = @@prev_negative_word ? POSITIVE : NEGATIVE_WORD

      #state
  end
  def positive
    #puts "next token is positive"
    set_interim_noun_verb(true)
    @state = NEGATIVE_WORD

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
    @state = if_interim_then_state_is(NEGATIVE_PHRASE, SUGGESTIVE)
    #puts "next token is suggestive"
  end
  def get_state
    #puts "negative_word"
    @state = NEGATED
  end
end
class NegativePhraseState < SentenceState
  def negative_word
    @state = if_interim_then_state_is(NEGATIVE_WORD, POSITIVE)
    #puts "next token is negative"
  end
  def positive
    set_interim_noun_verb(true)
    @state = NEGATIVE_PHRASE
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
    @state = NEGATED
  end
end
class SuggestiveState < SentenceState
  def negative_word
    @state = SUGGESTIVE
    #puts "next token is negative"
  end
  def positive
    @state = SUGGESTIVE
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
    #puts "suggestive"
    SUGGESTIVE
  end
end
class NegativeDescriptorState < SentenceState
  def negative_word
    @state = if_interim_then_state_is(NEGATIVE_WORD, POSITIVE)
    #puts "next token is negative"
  end
  def positive
    set_interim_noun_verb(true)
    @state = NEGATIVE_DESCRIPTOR
    #puts "next token is positive"
  end
  def negative_descriptor
    @state = if_interim_then_state_is(NEGATIVE_DESCRIPTOR, POSITIVE)
    #puts "next token is negative"
  end
  def negative_phrase
    @state = if_interim_then_state_is(NEGATIVE_PHRASE, POSITIVE)
    #puts "next token is negative phrase"
  end
  def suggestive
    @state = SUGGESTIVE #e.g.:"I hardly(-) suggested(S) ..."
    #puts "next token is suggestive"
  end
  def get_state
    #puts "negative_descriptor"
    NEGATED
  end

end
