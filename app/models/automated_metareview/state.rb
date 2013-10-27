require 'automated_metareview/negations'
require 'automated_metareview/constants'
class State
  @current_token_type
  def State.factory(state)
    {POSITIVE => PositiveState, NEGATIVE_DESCRIPTOR => NegativeDescriptorState, NEGATIVE_PHRASE => NegativePhraseState, SUGGESTIVE => SuggestiveState, NEGATIVE_WORD => NegativeWordState}[state].new
  end
end
class PositiveState < State
  @state
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    if(current_token_type != POSITIVE)
      state = current_token_type
    end


    return state, interim_noun_verb

  end
  def get_state
    puts "positive"
    return POSITIVE
  end

end
class NegativeWordState < State
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    if(current_token_type == NEGATIVE_WORD)
      #these words embellish the negation, so only if the previous word was not one of them you make it positive
      if(prev_negative_word.casecmp("NO") != 0 and prev_negative_word.casecmp("NEVER") != 0 and prev_negative_word.casecmp("NONE") != 0)
        state = POSITIVE #e.g: "not had no work..", "doesn't have no work..", "its not that it doesn't bother me..."
      else
        state = NEGATIVE_WORD #e.g: "no it doesn't help", "no there is no use for ..."
      end
      #interim_noun_verb = false #resetting
    elsif(current_token_type == NEGATIVE_DESCRIPTOR or current_token_type == NEGATIVE_PHRASE)
      state = POSITIVE #e.g.: "not bad", "not taken from", "I don't want nothing", "no code duplication"// ["It couldn't be more confusing.."- anomaly we dont handle this for now!]
      #interim_noun_verb = false #resetting
    elsif(current_token_type == SUGGESTIVE)
      #e.g. " it is not too useful as people could...", what about this one?
      if(interim_noun_verb == true) #there are some words in between
        state = NEGATIVE_WORD
      else
        state = SUGGESTIVE #e.g.:"I do not(-) suggest(S) ..."
      end

    end
    interim_noun_verb = false #resetting

    return state, interim_noun_verb
  end
  def get_state
    puts "negative_word"
    return NEGATIVE_WORD
  end
end
class NegativePhraseState < State
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    if(current_token_type == NEGATIVE_WORD)
      if(interim_noun_verb == true)#there are some words in between
        state = NEGATIVE_WORD #e.g."It is too short the text and doesn't"
      else
        state = POSITIVE #e.g."It is too short not to contain.."
      end
      interim_noun_verb = false #resetting
    elsif(current_token_type == NEGATIVE_DESCRIPTOR)
      state = NEGATIVE_DESCRIPTOR #e.g."It is too short barely covering..."
                                #interim_noun_verb = false #resetting
    elsif(current_token_type == NEGATIVE_PHRASE)
      state = NEGATIVE_PHRASE #e.g.:"it is too short, taken from ..."
                                #interim_noun_verb = false #resetting
    elsif(current_token_type == SUGGESTIVE)
      state = SUGGESTIVE #e.g.:"I too short and I suggest ..."
    end
    interim_noun_verb = false #resetting

    return state, interim_noun_verb
  end
  def get_state
    puts "negative phrase"
    return NEGATIVE_PHRASE
  end
end
class SuggestiveState < State
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    if(current_token_type == NEGATIVE_DESCRIPTOR)
      state = NEGATIVE_DESCRIPTOR
    elsif(current_token_type == NEGATIVE_PHRASE)
      state = NEGATIVE_PHRASE
    end
    #e.g.:"I suggest you don't.." -> suggestive
    interim_noun_verb = false #resetting

    return state , interim_noun_verb
  end
  def get_state
    puts "suggestive"
    return SUGGESTIVE
  end
end
class NegativeDescriptorState < State
  def next_state(current_token_type, prev_negative_word, interim_noun_verb)
    state = get_state()
    if(current_token_type == NEGATIVE_WORD)
      if(interim_noun_verb == true)#there are some words in between
        state = NEGATIVE_WORD #e.g: "hard(-) to understand none(-) of the comments"
      else
        state = POSITIVE #e.g."He hardly not...."
      end
      interim_noun_verb = false #resetting
    elsif(current_token_type == NEGATIVE_DESCRIPTOR)
      if(interim_noun_verb == true)#there are some words in between
        state = NEGATIVE_DESCRIPTOR #e.g:"there is barely any code duplication"
      else
        state = POSITIVE #e.g."It is hardly confusing..", but what about "it is a little confusing.."
      end
      interim_noun_verb = false #resetting
    elsif(current_token_type == NEGATIVE_PHRASE)
      if(interim_noun_verb == true)#there are some words in between
        state = NEGATIVE_PHRASE #e.g:"there is barely any code duplication"
      else
        state = POSITIVE #e.g.:"it is hard and appears to be taken from"
      end
                                #interim_noun_verb = false #resetting
    elsif(current_token_type == SUGGESTIVE)
      state = SUGGESTIVE #e.g.:"I hardly(-) suggested(S) ..."

    end
    interim_noun_verb = false #resetting

    return state, interim_noun_verb
  end
  def get_state
    puts "negative_descriptor"
    return NEGATIVE_DESCRIPTOR
  end

end