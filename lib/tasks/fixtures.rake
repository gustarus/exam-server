namespace :fixtures do
  include ActionView::Helpers::TextHelper

  desc 'Generate quiz via lorem ipsum.'
  task :generate_quiz, [:questions_count, :options_count] => :environment do |t, args|
    # parse task params
    questions_count = args[:questions_count] ? args[:questions_count].strip.to_i : 3
    options_count = args[:options_count] ? args[:options_count].strip.to_i : 3

    puts "\nGenerate quiz with #{pluralize(questions_count, 'question')} and #{pluralize(options_count, 'option')} in every question."

    # create quiz
    quiz = create_quiz
    # create questions
    (1..questions_count).each do
      question = create_question(quiz)
      # create options
      (1..options_count).each do |i|
        create_option(question, i - 1)
      end
    end

    puts "Done! Look at question with following command: \n $ open #{Settings.baseUrl}/admin/quiz/#{quiz.id.to_s}"
  end

  desc 'Generate quizes via lorem ipsum.'
  task :generate_quizes, [:count, :questions_count, :options_count] => :environment do |t, args|
    count = args[:count] ? args[:count].strip.to_i : 3

    puts "\nGenerate #{pluralize(count, 'quiz')}."
    (1..count).each do
      Rake::Task['fixtures:generate_quiz'].execute(args)
    end

    puts "\nDone!"
  end

  private

  def create_quiz
    Quiz.create!(title: "Generated quiz ##{Forgery('basic').text}")
  end

  def create_question(quiz)
    quiz.questions.create!(
      type: 'checkbox',
      title: 'Question title',
      content: "Generated question ##{Forgery('basic').text}. Every answer has own weight."
    )
  end

  def create_option(question, weight)
    question.options.create!(
      value: "Answer with weight #{pluralize(weight, 'point')}.",
      weight: weight
    )
  end
end
