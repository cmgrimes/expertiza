require 'automated_metareview/text_preprocessing'
require 'automated_metareview/constants'
require 'automated_metareview/graph_generator'
require 'ruby-web-search'

class PlagiarismChecker
=begin
 reviewText and submText are array containing review and submission texts 
=end
  def compare_reviews_with_submissions(review_text, subm_text)
    result = false

    review_text.each do |review_arr| #iterating through the review's sentences

      review = review_arr.to_s

      subm_text.each do |subm_arr|
        #iterating though the submission's sentences
        submission = subm_arr.to_s

        rev_len = 0

        #review's tokens, taking 'n' at a time
        array = review.split(" ")

        while(rev_len < array.length) do

          rev_len, rev_phrase = skip_empty_array(array, rev_len)

          add = 0 #add on to this when empty strings found

          for j in rev_len + 1..(NGRAM + rev_len + add-1) #concatenating 'n' tokens
            if j < array.length

              if array[j] == "" #skipping empty

                add += 1

              end
              rev_phrase += " "+  array[j]
            end
          end

          if j == array.length
            #if j has reached the end of the array, then reset rev_len to the end of array to, or shorter strings will be compared
            rev_len = j
          end

          #replacing punctuation


          submission = TextPreprocessing.new.contains_punct(submission)
          rev_phrase = TextPreprocessing.new.contains_punct(rev_phrase)


          #checking if submission contains the review and that only NGRAM number of review tokens are compared
          if(rev_phrase.split(" ").length == NGRAM and submission.downcase.include?(rev_phrase.downcase))
            result = true
            break
          end

          rev_len += 1

        end #end of the while loop

      end #end of loop for submission

    end
    #end of loop for reviews
    result

  end



#-------------------------

=begin
 Checking if the response has been copied from the review questions.
=end
  def compare_reviews_with_questions(auto_metareview)

    review_text_arr = auto_metareview.review_array

    scores = Score.find(:all, :conditions => ["response_id = ?", response.id])

    questions = Array.new

    #fetching the questions for the responses
    for i in 0..scores.length - 1
      questions << Question.find_by_sql(["Select * from questions where id = ?", scores[i].question_id])[0].txt
    end


    count_copies = 0 #count of the number of responses that are copies either of questions of other responses
    rev_array = Array.new #holds the non-plagiairised responses
    #comparing questions with text
    for i in 0..scores.length - 1
      if(!questions[i].nil? and !review_text_arr[i].nil? and questions[i].downcase == review_text_arr[i].downcase)
        count_copies+=1

      end

      #comparing response with other responses

    end


    #setting @review_array as rev_array
    check_plagiarism_state(auto_metareview, count_copies, rev_array, scores)

  end


=begin
    Checking if the response has been copied from other responses submitted.
=end
  def compare_reviews_with_responses(auto_metareview, map_id)
    review_text_arr = auto_metareview.review_array
    response = Response.find(:first, :conditions => ["map_id = ?", map_id])
    scores = Score.find(:all, :conditions => ["response_id = ?", response.id])

    #fetching the questions for the responses


    count_copies = 0 #count of the number of responses that are copies either of questions of other responses
    rev_array = Array.new #holds the non-plagiairised responses



    #comparing response with other responses
    flag = 0
    for j in 0..review_text_arr.length - 1
      if(i != j and !review_text_arr[i].nil? and !review_text_arr[j].nil? and review_text_arr[i].downcase == review_text_arr[j].downcase)
        count_copies+=1
        flag = 1
        break
      end
    end

    if(flag == 0) #ensuring no match with any of the review array's responses
      rev_array << review_text_arr[i]
    end


    #setting @review_array as rev_array
    check_plagiarism_state(auto_metareview, count_copies, rev_array, scores)

  end



=begin
 Checking if the response was copied from google 
=end
  def compare_reviews_with_google_search(auto_metareview)
    review_text_arr = auto_metareview.review_array

    flag = false
    temp_array = Array.new

    review_text_arr.each{
        |rev_text|
      if(!rev_text.nil?)
        #placing the search text within quotes to search exact match for the complete text
        response = RubyWebSearch::Google.search(:query => "\""+ rev_text +"\"")
        #if the results are greater than 0, then the text has been copied
        if(response.results.length > 0)
          flag = true
        else
          temp_array << rev_text #copying the non-plagiarised text for evaluation
        end
      end
    }
    #setting temp_array as the @review_array
    auto_metareview.review_array = temp_array

    flag

  end

end

# to check whether a review is ALL_RESPONSES_PLAGIARISED or SOME_RESPONSES_PLAGIARISED
def check_plagiarism_state(auto_metareview, count_copies, rev_array, scores)
  if count_copies > 0 #resetting review_array only when plagiarism was found
    auto_metareview.review_array = rev_array


    if count_copies == scores.length
      return ALL_RESPONSES_PLAGIARISED #plagiarism, with all other metrics 0
    else
      return SOME_RESPONSES_PLAGIARISED #plagiarism, while evaluating other metrics
    end
  end
end

def skip_empty_array(array, rev_len)

  if (array[rev_len] == " ") #skipping empty

    rev_len+=1

  end

  #generating the sentence segment you'd like to compare
  rev_phrase = array[rev_len]
  return rev_len, rev_phrase

end